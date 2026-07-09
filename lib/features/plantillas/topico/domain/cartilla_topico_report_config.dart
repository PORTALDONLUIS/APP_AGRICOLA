import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_topico_config.dart';

final cartillaTopicoReportConfig = CartillaReportConfig(
  templateKey: CartillaTopicoConfig.templateKeyStatic,
  title: 'TOPICO',
  dailyReport: true,
  transposeMetrics: false,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: const [
    ReportGroupByConfig(
      key: 'atencion',
      label: 'Atencion',
      path: '_meta.localId',
    ),
  ],
  columns: const [
    ReportColumnConfig.dimension(
      key: 'atencion',
      label: 'Atencion',
      path: '_meta.localId',
      hidden: true,
    ),
    ReportColumnConfig.dimension(
      key: 'dni',
      label: 'DNI',
      path: 'body.${CartillaTopicoConfig.kDni}',
    ),
    ReportColumnConfig.dimension(
      key: 'pacienteNombre',
      label: 'Nombres y apellidos',
      path: 'body.${CartillaTopicoConfig.kPacienteNombre}',
    ),
    ReportColumnConfig.dimension(
      key: 'area',
      label: 'Area',
      path: 'body.${CartillaTopicoConfig.kArea}',
    ),
    ReportColumnConfig.dimension(
      key: 'regimen',
      label: 'Regimen',
      path: 'body.${CartillaTopicoConfig.kPlanilla}',
    ),
    ReportColumnConfig.dimension(
      key: 'aptitud',
      label: 'Aptitud',
      path: 'body.${CartillaTopicoConfig.kAptitud}',
    ),
    ReportColumnConfig.dimension(
      key: 'tipoAtencion',
      label: 'Tipo Atencion',
      path: 'body.${CartillaTopicoConfig.kTipoAtencion}',
    ),
    ReportColumnConfig.dimension(
      key: 'diagnosticoObservacion',
      label: 'Diagnostico / Observacion',
      path: 'body.${CartillaTopicoConfig.kDiagnosticoObservacion}',
    ),
    ReportColumnConfig.dimension(
      key: 'medicamentos',
      label: 'Medicamentos',
      path: 'body.${CartillaTopicoConfig.kMedicamento}',
      format: 'topicoMedicamentos',
    ),
  ],
);
