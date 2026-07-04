import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/storage/drift/daos/master/actividad_labores_dao.dart';
import '../../../core/storage/drift/daos/master/campanias_dao.dart';
import '../../../core/storage/drift/daos/master/lote_orillas_dao.dart';
import '../../../core/storage/drift/daos/master/lotes_dao.dart';
import '../../../core/storage/drift/daos/master/persona_tipos_dao.dart';
import '../../../core/storage/drift/daos/master/personas_dao.dart';
import '../../../core/storage/drift/daos/master/topico_consultas_dao.dart';
import '../../../core/storage/drift/daos/master/topico_empresas_dao.dart';
import '../../../core/storage/drift/daos/master/topico_medicamentos_dao.dart';
import '../../../core/storage/drift/daos/master/topico_pacientes_dao.dart';
import '../../../core/storage/drift/daos/master/variedades_dao.dart';
import '../../../core/storage/drift/daos/sync_cursor_dao.dart';
import '../data/master_local_ds.dart';
import '../data/master_remote_ds.dart';
import '../data/master_repository.dart';
import 'master_sync_controller.dart';

final masterRemoteDsProvider = Provider<MasterRemoteDs>((ref) {
  final dio = ref.read(dioClientProvider);
  return MasterRemoteDs(dio);
});

final masterLocalDsProvider = Provider<MasterLocalDs>((ref) {
  final db = ref.read(appDatabaseProvider);
  return MasterLocalDs(
    campaniasDao: CampaniasDao(db),
    lotesDao: LotesDao(db),
    loteOrillasDao: LoteOrillasDao(db),
    variedadesDao: VariedadesDao(db),
    personaTiposDao: PersonaTiposDao(db),
    personasDao: PersonasDao(db),
    actividadLaboresDao: ActividadLaboresDao(db),
    topicoEmpresasDao: TopicoEmpresasDao(db),
    topicoPacientesDao: TopicoPacientesDao(db),
    topicoConsultasDao: TopicoConsultasDao(db),
    topicoMedicamentosDao: TopicoMedicamentosDao(db),
  );
});

final masterRepositoryProvider = Provider<MasterRepository>((ref) {
  return MasterRepository(
    remote: ref.read(masterRemoteDsProvider),
    local: ref.read(masterLocalDsProvider),
    personasRemote: ref.read(personasRemoteProvider),
  );
});

final masterSyncControllerProvider =
    StateNotifierProvider<MasterSyncController, MasterSyncState>((ref) {
      final db = ref.read(appDatabaseProvider);
      return MasterSyncController(
        repo: ref.read(masterRepositoryProvider),
        cursorDao: SyncCursorDao(db),
      );
    });

// Streams para combos (offline)
final campaniasStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchCampanias();
});

final lotesStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchLotes();
});

final variedadesStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchVariedades();
});

final personaTiposStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchPersonaTiposActivos();
});

final personasActivasStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchPersonasActivas();
});

final actividadLaboresStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchActividadLaboresActivas();
});

final topicoEmpresasStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchTopicoEmpresas();
});

final topicoPacientesStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchTopicoPacientes();
});

final topicoPacientesSearchProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String>((ref, query) {
      return ref
          .read(masterLocalDsProvider)
          .searchTopicoPacientes(query, limit: 20);
    });

final topicoConsultasStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchTopicoConsultas();
});

final topicoMedicamentosStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchTopicoMedicamentos();
});

final laboresByActividadProvider = StreamProvider.family<List<dynamic>, String>(
  (ref, actividadId) {
    return ref.read(masterLocalDsProvider).watchLaboresByActividad(actividadId);
  },
);

final personasActivasByTipoCodigoProvider =
    StreamProvider.family<List<dynamic>, String>((ref, codigo) {
      return ref
          .read(masterLocalDsProvider)
          .watchPersonasActivasByTipoCodigo(codigo);
    });

final personasActivasByTipoIdProvider =
    StreamProvider.family<List<dynamic>, int>((ref, tipoId) {
      return ref
          .read(masterLocalDsProvider)
          .watchPersonasActivasByTipoId(tipoId);
    });

bool _matchesTipo(
  dynamic persona,
  List<String> acceptedCodes,
  List<String> acceptedLabels,
) {
  try {
    final map = (persona as dynamic).toJson().cast<String, dynamic>();
    final codigo = _normalizeTipoText(
      '${map['tipoCodigo'] ?? map['tipo_codigo'] ?? ''}',
    );
    final descripcion = _normalizeTipoText(
      '${map['tipoDescripcion'] ?? map['tipo_descripcion'] ?? ''}',
    );

    final normalizedCodes = acceptedCodes.map(_normalizeTipoText).toSet();
    if (normalizedCodes.contains(codigo)) {
      return true;
    }

    for (final label in acceptedLabels) {
      if (descripcion.contains(_normalizeTipoText(label))) {
        return true;
      }
    }
  } catch (_) {}

  return false;
}

String _normalizeTipoText(String value) {
  return value
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÁÀÄÂ]'), 'A')
      .replaceAll(RegExp(r'[ÉÈËÊ]'), 'E')
      .replaceAll(RegExp(r'[ÍÌÏÎ]'), 'I')
      .replaceAll(RegExp(r'[ÓÒÖÔ]'), 'O')
      .replaceAll(RegExp(r'[ÚÙÜÛ]'), 'U')
      .replaceAll('Ñ', 'N')
      .replaceAll(RegExp(r'[^A-Z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

final personasPodActivasStreamProvider = StreamProvider((ref) {
  return ref
      .read(masterLocalDsProvider)
      .watchPersonasActivas()
      .map(
        (items) => items
            .where(
              (persona) => _matchesTipo(
                persona,
                const ['OPE', 'OPERARIO'],
                const ['OPERARIO'],
              ),
            )
            .toList(),
      );
});

final personasSupActivasStreamProvider = StreamProvider((ref) {
  return ref
      .read(masterLocalDsProvider)
      .watchPersonasActivas()
      .map(
        (items) => items
            .where(
              (persona) => _matchesTipo(
                persona,
                const ['SUP', 'SUPERVISOR'],
                const ['SUPERVISOR'],
              ),
            )
            .toList(),
      );
});

final personasResponsableInspeccionActivasStreamProvider = StreamProvider((
  ref,
) {
  return ref
      .read(masterLocalDsProvider)
      .watchPersonasActivas()
      .map(
        (items) => items
            .where(
              (persona) => _matchesTipo(
                persona,
                const ['RI', 'RIN', 'RESPONSABLE INSPECCION'],
                const ['RESPONSABLE DE INSPECCION', 'RESPONSABLE INSPECCION'],
              ),
            )
            .toList(),
      );
});

final personasJorActivasStreamProvider = StreamProvider((ref) {
  return ref
      .read(masterLocalDsProvider)
      .watchPersonasActivasByTipoCodigo('JOR');
});

/// Orillas por lote (para BRIX cuando fenología = ORILLA).
final orillasByLoteProvider = StreamProvider.family<List<dynamic>, int>((
  ref,
  idLote,
) {
  return ref.read(masterLocalDsProvider).watchOrillasByLoteId(idLote);
});
