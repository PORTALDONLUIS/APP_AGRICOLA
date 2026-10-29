import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:donluis_forms/core/network/dio_client.dart';
import 'package:donluis_forms/core/storage/session_store.dart';
import 'package:donluis_forms/core/storage/token_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Solo pruebas: usar servidor loopback en lugar del HTTP ficticio de widgets.
  HttpOverrides.global = null;
  const storage = FlutterSecureStorage();
  const session = SessionStore(storage);
  const tokens = TokenStore(storage);

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('sesión anterior vencida se conserva con su usuario', () async {
    FlutterSecureStorage.setMockInitialValues({
      'session.userId': '7',
      'session.offlineExpiresAt': '2000-01-01T00:00:00',
    });
    expect(await session.isOfflineSessionValid(), isTrue);
  });

  test('sesión nueva persiste sin plazo y cierre manual la borra', () async {
    await session.saveOfflineSession(userId: 7, isSuperadmin: false);
    expect(await storage.read(key: 'session.offlineExpiresAt'), isNull);
    expect(await session.isOfflineSessionValid(), isTrue);
    await session.clear();
    expect(await session.isOfflineSessionValid(), isFalse);
  });

  test('no existe sesión sin usuario y tokens se borran al cerrar', () async {
    expect(await session.isOfflineSessionValid(), isFalse);
    await tokens.saveUserId(7);
    await tokens.saveTokens(access: 'access', refresh: 'refresh');
    await tokens.saveOfflineSessionUntil(DateTime(2000));
    expect(await tokens.hasValidOfflineSession(), isTrue);
    await tokens.clear();
    expect(await tokens.hasValidOfflineSession(), isFalse);
  });
  test(
    'renueva una sola vez ante peticiones simultáneas y guarda ambos tokens',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      var renewals = 0;
      server.listen((request) async {
        request.response.headers.contentType = ContentType.json;
        if (request.uri.path == '/api/auth/refresh/') {
          renewals++;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          request.response.write(
            jsonEncode({'access': 'new', 'refresh': 'persistent'}),
          );
        } else if (request.headers.value('Authorization') == 'Bearer new') {
          request.response.write('{}');
        } else {
          request.response.statusCode = 401;
          request.response.write('{}');
        }
        await request.response.close();
      });
      await tokens.saveTokens(access: 'old', refresh: 'legacy');
      final client = DioClient(
        baseUrl: 'http://127.0.0.1:${server.port}',
        tokenStore: tokens,
      );
      addTearDown(() => client.dio.close(force: true));
      await Future.wait([client.dio.get('/one'), client.dio.get('/two')]);
      expect(renewals, 1);
      expect(await tokens.getAccessToken(), 'new');
      expect(await tokens.getRefreshToken(), 'persistent');
    },
  );

  test(
    'falla temporal conserva tokens; rechazo confirmado cierra sesión',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      var refreshStatus = 503;
      server.listen((request) async {
        request.response.statusCode = request.uri.path == '/api/auth/refresh/'
            ? refreshStatus
            : 401;
        request.response.headers.contentType = ContentType.json;
        request.response.write('{}');
        await request.response.close();
      });
      var closed = 0;
      final client = DioClient(
        baseUrl: 'http://127.0.0.1:${server.port}',
        tokenStore: tokens,
        onSessionExpired: () async {
          closed++;
        },
      );
      addTearDown(() => client.dio.close(force: true));
      await tokens.saveTokens(access: 'old', refresh: 'persistent');
      expect(
        await client.refreshSessionOnAppStart(),
        SessionRefreshStatus.unavailable,
      );
      expect(await tokens.getRefreshToken(), 'persistent');
      await expectLater(client.dio.get('/one'), throwsA(isA<DioException>()));
      expect(await tokens.getRefreshToken(), 'persistent');
      expect(closed, 0);
      refreshStatus = 401;
      await expectLater(client.dio.get('/one'), throwsA(isA<DioException>()));
      expect(await tokens.getRefreshToken(), isNull);
      expect(closed, 1);
    },
  );
}
