import 'cartilla_report_config.dart';

const portabinReportConfig = CartillaReportConfig(
  templateKey: 'cartilla_portabin_carretas',
  title: 'PORTABIN / CARRETAS',
  dailyReport: true,
  allowedEstados: ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(key: 'lote', label: 'Lote', path: 'header.loteId'),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.loteId',
    ),
    ReportColumnConfig.metric(
      key: 'muestras',
      label: 'Muestras',
      path: 'body.fecha',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'contenedores',
      label: 'Bines / jabas',
      path: 'body.nroBinJabas',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
  ],
);

const movilidadesReportConfig = CartillaReportConfig(
  templateKey: 'cartilla_movilidades_cosecha',
  title: 'MOVILIDADES COSECHA',
  dailyReport: true,
  allowedEstados: ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [],
  columns: [
    ReportColumnConfig.metric(
      key: 'viajes',
      label: 'Cargas / viajes',
      path: 'body.fecha',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'camiones',
      label: 'Camiones distintos',
      path: 'body.placa',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'guias',
      label: 'Guías distintas',
      path: 'body.cantidadGuias',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'cajas',
      label: 'Total cajas',
      path: 'body.totalCajas',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
  ],
);
