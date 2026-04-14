enum ReportColumnKind {
  dimension,
  metric,
  computed,
}

enum ReportAggregationType {
  sum,
  countRows,
}

enum ReportComputationType {
  sumColumns,
  percentage,
}

class CartillaReportConfig {
  final String templateKey;
  final String title;
  final bool dailyReport;
  final List<String> allowedEstados;
  final List<ReportGroupByConfig> groupBy;
  final List<ReportColumnConfig> columns;

  /// Si es true, la UI muestra filas = métricas y columnas = grupos (p. ej. lotes).
  final bool displayTransposed;

  const CartillaReportConfig({
    required this.templateKey,
    required this.title,
    required this.dailyReport,
    required this.allowedEstados,
    required this.groupBy,
    required this.columns,
    this.displayTransposed = false,
  });
}

class ReportGroupByConfig {
  final String key;
  final String label;
  final String path;

  const ReportGroupByConfig({
    required this.key,
    required this.label,
    required this.path,
  });
}

class ReportColumnConfig {
  final String key;
  final String label;
  final ReportColumnKind kind;

  // dimension / metric
  final String? path;

  // metric
  final ReportAggregationType? aggregation;

  // computed
  final ReportComputationConfig? computation;

  final String? format;
  final bool hidden;

  const ReportColumnConfig({
    required this.key,
    required this.label,
    required this.kind,
    this.path,
    this.aggregation,
    this.computation,
    this.format,
    this.hidden = false,
  });

  const ReportColumnConfig.dimension({
    required String key,
    required String label,
    required String path,
    String? format,
    bool hidden = false,
  }) : this(
          key: key,
          label: label,
          kind: ReportColumnKind.dimension,
          path: path,
          format: format,
          hidden: hidden,
        );

  const ReportColumnConfig.metric({
    required String key,
    required String label,
    required String path,
    required ReportAggregationType aggregation,
    String? format,
    bool hidden = false,
  }) : this(
          key: key,
          label: label,
          kind: ReportColumnKind.metric,
          path: path,
          aggregation: aggregation,
          format: format,
          hidden: hidden,
        );

  const ReportColumnConfig.computed({
    required String key,
    required String label,
    required ReportComputationConfig computation,
    String? format,
    bool hidden = false,
  }) : this(
          key: key,
          label: label,
          kind: ReportColumnKind.computed,
          computation: computation,
          format: format,
          hidden: hidden,
        );
}

class ReportComputationConfig {
  final ReportComputationType type;
  final List<String>? sourceColumnKeys;
  final String? numeratorColumnKey;
  final String? denominatorColumnKey;

  const ReportComputationConfig({
    required this.type,
    this.sourceColumnKeys,
    this.numeratorColumnKey,
    this.denominatorColumnKey,
  });

  const ReportComputationConfig.sumColumns({
    required List<String> sourceColumnKeys,
  }) : this(
          type: ReportComputationType.sumColumns,
          sourceColumnKeys: sourceColumnKeys,
        );

  const ReportComputationConfig.percentage({
    required String numeratorColumnKey,
    required String denominatorColumnKey,
  }) : this(
          type: ReportComputationType.percentage,
          numeratorColumnKey: numeratorColumnKey,
          denominatorColumnKey: denominatorColumnKey,
        );
}