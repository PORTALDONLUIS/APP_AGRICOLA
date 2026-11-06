import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../tic/tic_scan.dart';

class CartillaAsistenciaPage extends ConsumerStatefulWidget {
  const CartillaAsistenciaPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<CartillaAsistenciaPage> createState() =>
      _CartillaAsistenciaPageState();
}

class _CartillaAsistenciaPageState
    extends ConsumerState<CartillaAsistenciaPage> {
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  List<Map<String, dynamic>> _sedes = const [];
  Map<String, dynamic>? _sede;
  Map<String, dynamic>? _geo;
  Map<String, dynamic>? _lastMark;
  String? _error;
  bool _loadingSedes = true;
  bool _capturingLocation = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSedes();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSedes() async {
    setState(() {
      _loadingSedes = true;
      _error = null;
    });
    try {
      final response = await ref.read(dioClientProvider).dio.get(
            '/api/asistencia/sedes/',
          );
      final raw = (response.data as Map)['items'] as List? ?? const [];
      if (!mounted) return;
      setState(() {
        _sedes = raw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _loadingSedes = false);
    }
  }

  Future<void> _captureLocation() async {
    setState(() => _capturingLocation = true);
    try {
      final geo = await ref.read(locationServiceProvider).tryGetHeaderGeo(
            timeout: const Duration(seconds: 8),
            streamTimeout: const Duration(seconds: 8),
            maxAge: const Duration(minutes: 2),
            maxAccuracyMeters: 50,
          );
      if (!mounted) return;
      if (geo == null) {
        _show('No se obtuvo una ubicación precisa. Activa el GPS y vuelve a intentar.');
        return;
      }
      setState(() => _geo = geo);
    } finally {
      if (mounted) setState(() => _capturingLocation = false);
    }
  }

  Future<void> _scan() async {
    final code = await scanTicCode(context);
    if (!mounted || code == null || code.isEmpty) return;
    _codeController.text = code;
    setState(() {});
  }

  Future<void> _mark() async {
    final sede = _sede;
    final geo = _geo;
    final code = _codeController.text.trim();
    if (sede == null || geo == null || code.isEmpty) {
      _show('Selecciona sede, captura GPS e ingresa o escanea el DNI.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final result = await ref.read(dioClientProvider).dio.post(
            '/api/asistencia/marcar/',
            data: {
              'sedeId': sede['id'],
              'codigoPersonal': code,
              'latitud': geo['lat'],
              'longitud': geo['lon'],
              'precision': geo['gpsAccuracy'],
            },
          );
      if (!mounted) return;
      setState(() {
        _lastMark = Map<String, dynamic>.from(result.data as Map);
        _codeController.clear();
      });
      _codeFocus.requestFocus();
    } catch (error) {
      if (mounted) _show(_errorText(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _errorText(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) return '${data['detail']}';
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'No hay conexión con el servidor de asistencia.';
      }
    }
    return 'No se pudo completar la operación. Intenta nuevamente.';
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _sede == null ? _buildSedes() : _buildMarker(),
    );
  }

  Widget _buildSedes() {
    if (_loadingSedes) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadSedes,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sedes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sede = _sedes[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(child: Icon(Icons.location_on_outlined)),
            title: Text('${sede['nombre'] ?? 'Sede'}'),
            subtitle: Text('Empresa: ${sede['empresaId'] ?? '-'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() {
              _sede = sede;
              _geo = null;
              _lastMark = null;
            }),
          ),
        );
      },
    );
  }

  Widget _buildMarker() {
    final geo = _geo;
    final mark = _lastMark;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.location_on, color: DonLuisColors.primary),
            title: Text('${_sede!['nombre']}'),
            subtitle: Text('Empresa: ${_sede!['empresaId'] ?? '-'}'),
            trailing: TextButton(
              onPressed: () => setState(() {
                _sede = null;
                _geo = null;
                _lastMark = null;
              }),
              child: const Text('Cambiar'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ubicación GPS', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(geo == null
                    ? 'Requerida para validar la marcación.'
                    : 'GPS capturado · precisión ${((geo['gpsAccuracy'] as num?) ?? 0).toStringAsFixed(0)} m'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _capturingLocation ? null : _captureLocation,
                  icon: _capturingLocation
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location),
                  label: Text(_capturingLocation ? 'Capturando ubicación...' : 'Capturar ubicación'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.qr_code_scanner, size: 48, color: DonLuisColors.primary),
                const SizedBox(height: 8),
                const Text('Ingrese o escanee el DNI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _codeController,
                  focusNode: _codeFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _mark(),
                  decoration: InputDecoration(
                    labelText: 'DNI / código de barras',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    suffixIcon: IconButton(
                      tooltip: 'Escanear con cámara',
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scan,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : _mark,
                    icon: _submitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.how_to_reg),
                    label: Text(_submitting ? 'Registrando...' : 'Registrar marcación'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (mark != null) ...[
          const SizedBox(height: 16),
          Card(
            color: DonLuisColors.secondary.withValues(alpha: .10),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: DonLuisColors.secondary),
              title: Text('${mark['action'] == 'salida' ? 'Salida' : 'Ingreso'} registrado'),
              subtitle: Text('${mark['nombreCompleto']}\n${mark['codigoPersonal']} · ${mark['hora']}'),
              isThreeLine: true,
            ),
          ),
        ],
      ],
    );
  }
}
