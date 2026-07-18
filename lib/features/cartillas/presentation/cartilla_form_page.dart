import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../core/storage/drift/app_database.dart';
import '../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../../shared/widgets/donluis_section_card.dart';
import '../../../shared/widgets/donluis_app_bar.dart';
import '../../plantillas/brix/domain/cartilla_brix_config.dart';
import '../../plantillas/fertilidad/domain/cartilla_fertilidad_config.dart';
import '../../plantillas/fitosanidad/presentation/widgets/numeric_stepper_field.dart';
import '../../plantillas/poda/domain/cartilla_poda_config.dart';
import '../../plantillas/registro_personal_garita_seguridad/domain/cartilla_registro_personal_garita_seguridad_config.dart';
import '../../plantillas/supervision_labor/domain/cartilla_supervision_labor_config.dart';
import '../../plantillas/topico/domain/cartilla_topico_config.dart';
import '../application/cartilla_validator.dart';
import '../application/photo_service.dart';
import '../application/providers.dart';
import '../domain/cartilla_form_config.dart';
import '../domain/cartilla_form_models.dart';
import '../domain/cartilla_registry.dart';
import '../../registros/domain/registro.dart';

import '../presentation/widgets/photo_slot_field.dart';
import '../../../core/location/lote_geo_service.dart';
import '../../master/presentation/master_providers.dart';

/// Texto para items de dropdown: evita overflow con ellipsis.
Widget _dropdownItemText(String text) {
  return Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    softWrap: false,
  );
}

Widget _dropdownItemWithSubtitle(String label, {String? subtitle}) {
  final secondary = subtitle?.trim() ?? '';
  if (secondary.isEmpty) {
    return _dropdownItemText(label);
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
      const SizedBox(height: 2),
      Text(
        secondary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(
          fontSize: 12,
          color: DonLuisColors.primary.withValues(alpha: 0.72),
        ),
      ),
    ],
  );
}

/// Ítem del menú de orillas (BRIX — detalle fenología): permite leer el texto completo.
Widget _orillaDropdownMenuItemChild(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      softWrap: true,
      maxLines: 8,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

/// Texto mostrado en el campo cerrado (compacto); el menú usa [_orillaDropdownMenuItemChild].
Widget _orillaDropdownSelectedLabel(String text) {
  return Tooltip(
    message: text,
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
    ),
  );
}

class _SignaturePadField extends StatefulWidget {
  final String label;
  final dynamic value;
  final bool readOnly;
  final ValueChanged<List<List<Map<String, double>>>> onChanged;

  const _SignaturePadField({
    required this.label,
    required this.value,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  State<_SignaturePadField> createState() => _SignaturePadFieldState();
}

class _SignaturePadFieldState extends State<_SignaturePadField> {
  late List<List<Offset>> _strokes;
  int? _activePointer;

  @override
  void initState() {
    super.initState();
    _strokes = _decodeSignature(widget.value);
  }

  @override
  void didUpdateWidget(covariant _SignaturePadField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _strokes = _decodeSignature(widget.value);
    }
  }

  void _startStroke(Offset localPosition, Size size) {
    if (widget.readOnly) return;
    final point = _normalizePoint(localPosition, size);
    setState(() {
      _strokes = _mutableStrokes(_strokes)..add(<Offset>[point]);
    });
    _emit();
  }

  void _appendPoint(Offset localPosition, Size size) {
    if (widget.readOnly || _strokes.isEmpty) return;
    final point = _normalizePoint(localPosition, size);
    setState(() {
      final nextStrokes = _mutableStrokes(_strokes);
      nextStrokes.last.add(point);
      _strokes = nextStrokes;
    });
    _emit();
  }

  void _endStroke(int pointer) {
    if (_activePointer == pointer) {
      _activePointer = null;
    }
  }

  void _clear() {
    if (widget.readOnly) return;
    setState(() => _strokes = <List<Offset>>[]);
    widget.onChanged(const []);
  }

  void _emit() {
    widget.onChanged(
      _strokes
          .map((stroke) => stroke.map((p) => {'x': p.dx, 'y': p.dy}).toList())
          .toList(),
    );
  }

  Offset _normalizePoint(Offset p, Size size) {
    final width = size.width <= 0 ? 1.0 : size.width;
    final height = size.height <= 0 ? 1.0 : size.height;
    return Offset(
      (p.dx / width).clamp(0.0, 1.0),
      (p.dy / height).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        enabled: !widget.readOnly,
        suffixIcon: widget.readOnly
            ? const Icon(Icons.lock_outline, size: 18)
            : IconButton(
                tooltip: 'Limpiar firma',
                icon: const Icon(Icons.backspace_outlined, size: 18),
                onPressed: _strokes.isEmpty ? null : _clear,
              ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const height = 180.0;
          final size = Size(constraints.maxWidth, height);

          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: widget.readOnly
                ? null
                : (event) {
                    _activePointer = event.pointer;
                    _startStroke(event.localPosition, size);
                  },
            onPointerMove: widget.readOnly
                ? null
                : (event) {
                    if (_activePointer == event.pointer) {
                      _appendPoint(event.localPosition, size);
                    }
                  },
            onPointerUp: widget.readOnly
                ? null
                : (event) => _endStroke(event.pointer),
            onPointerCancel: widget.readOnly
                ? null
                : (event) => _endStroke(event.pointer),
            child: Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.readOnly
                    ? Theme.of(context).disabledColor.withValues(alpha: 0.04)
                    : Colors.white,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _SignaturePainter(
                  strokes: _strokes,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;

  const _SignaturePainter({required this.strokes, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        final p = _denormalize(stroke.first, size);
        canvas.drawCircle(p, 1.8, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }

      final path = Path()
        ..moveTo(
          _denormalize(stroke.first, size).dx,
          _denormalize(stroke.first, size).dy,
        );
      for (final point in stroke.skip(1)) {
        final p = _denormalize(point, size);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  Offset _denormalize(Offset p, Size size) {
    return Offset(p.dx * size.width, p.dy * size.height);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return true;
  }
}

List<List<Offset>> _decodeSignature(dynamic value) {
  if (value is! List) return [];

  return value
      .whereType<List>()
      .map((stroke) {
        return stroke
            .whereType<Map>()
            .map((point) {
              final x = point['x'];
              final y = point['y'];
              final dx = x is num ? x.toDouble() : double.tryParse('$x');
              final dy = y is num ? y.toDouble() : double.tryParse('$y');
              if (dx == null || dy == null) return null;
              return Offset(dx.clamp(0.0, 1.0), dy.clamp(0.0, 1.0));
            })
            .whereType<Offset>()
            .toList();
      })
      .where((stroke) => stroke.isNotEmpty)
      .toList();
}

List<List<Offset>> _mutableStrokes(List<List<Offset>> strokes) {
  return strokes.map((stroke) => List<Offset>.from(stroke)).toList();
}

String _textDataFromDropdownChild(Widget child) {
  if (child is Text) return child.data ?? '';
  return '';
}

class _GpsIndicatorState {
  const _GpsIndicatorState({
    this.lat,
    this.lon,
    this.accuracyMeters,
    this.updatedAt,
    this.searching = true,
  });

  final double? lat;
  final double? lon;
  final double? accuracyMeters;
  final DateTime? updatedAt;
  final bool searching;

  bool get hasFix => lat != null && lon != null;

  _GpsIndicatorState copyWith({
    double? lat,
    double? lon,
    double? accuracyMeters,
    DateTime? updatedAt,
    bool? searching,
  }) {
    return _GpsIndicatorState(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      updatedAt: updatedAt ?? this.updatedAt,
      searching: searching ?? this.searching,
    );
  }
}

Color _gpsIndicatorColor(_GpsIndicatorState state, ThemeData theme) {
  final accuracy = state.accuracyMeters;
  if (!state.hasFix || accuracy == null || !accuracy.isFinite) {
    return theme.colorScheme.onSurfaceVariant;
  }
  if (accuracy <= 15) return DonLuisColors.secondary;
  if (accuracy <= 35) return const Color(0xFFB7791F);
  return theme.colorScheme.error;
}

String _gpsIndicatorLabel(_GpsIndicatorState state) {
  if (!state.hasFix) {
    return state.searching ? 'GPS buscando...' : 'GPS no disponible';
  }

  final lat = state.lat!.toStringAsFixed(5);
  final lon = state.lon!.toStringAsFixed(5);
  final accuracy = state.accuracyMeters;
  final accuracyText = accuracy != null && accuracy.isFinite
      ? '${accuracy.toStringAsFixed(0)} m'
      : 's/p';
  final ageText = _gpsIndicatorAgeText(state.updatedAt);

  return 'GPS · $lat, $lon · $accuracyText$ageText';
}

String _gpsIndicatorAgeText(DateTime? updatedAt) {
  if (updatedAt == null) return '';

  final ageSeconds = DateTime.now()
      .difference(updatedAt)
      .inSeconds
      .clamp(0, 3599);
  if (ageSeconds < 3) return ' · ahora';
  if (ageSeconds < 60) return ' · hace ${ageSeconds}s';

  final minutes = (ageSeconds / 60).floor();
  return ' · hace ${minutes}min';
}

DateTime? _gpsDateFromGeo(Map<String, dynamic> geo) {
  final raw = geo['gpsDate'];
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  return DateTime.tryParse(raw.toString());
}

Widget _gpsIndicatorBar({
  required ValueListenable<_GpsIndicatorState> listenable,
}) {
  return ValueListenableBuilder<_GpsIndicatorState>(
    valueListenable: listenable,
    builder: (context, state, _) {
      final theme = Theme.of(context);
      final color = _gpsIndicatorColor(state, theme);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
        child: Align(
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: DonLuisColors.surfaceCard.withValues(alpha: 0.78),
                  border: Border.all(color: color.withValues(alpha: 0.22)),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.my_location, size: 15, color: color),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        _gpsIndicatorLabel(state),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => '$item'.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  if (value is String) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  return const [];
}

/// ✅ Mapper genérico para DataClass Drift (CampaniasTableData / LotesTableData)
/// Usa toJson() y busca llaves típicas para id/label.
/// Si tus columnas se llaman diferente, dime y lo afino 100%.
List<DropdownMenuItem<String>> _itemsFromDrift(List<dynamic> list) {
  Map<String, dynamic> toMap(dynamic x) {
    try {
      final m = (x as dynamic).toJson();
      if (m is Map) return m.cast<String, dynamic>();
    } catch (_) {}
    return <String, dynamic>{};
  }

  String pickId(Map<String, dynamic> m) {
    const idKeys = [
      'id',
      'codigo',
      'idCampania',
      'campaniaId',
      'idLote',
      'loteId',
      'idLoteOrilla',
      'loteOrillaId',
    ];
    for (final k in idKeys) {
      if (m.containsKey(k) && m[k] != null && '${m[k]}'.isNotEmpty) {
        return '${m[k]}';
      }
    }
    // fallback: primer campo no nulo
    for (final e in m.entries) {
      if (e.value != null && '${e.value}'.isNotEmpty) return '${e.value}';
    }
    return '';
  }

  String pickLabel(Map<String, dynamic> m, String id) {
    const labelKeys = [
      'nombre',
      'name',
      'descripcion',
      'label',
      'titulo',
      'codigo',
      'orillaLabel',
    ];
    for (final k in labelKeys) {
      if (m.containsKey(k) && m[k] != null && '${m[k]}'.isNotEmpty) {
        return '${m[k]}';
      }
    }
    return id;
  }

  final items = <DropdownMenuItem<String>>[];
  for (final x in list) {
    final m = toMap(x);
    final id = pickId(m);
    if (id.isEmpty) continue;
    final label = pickLabel(m, id);
    items.add(DropdownMenuItem(value: id, child: _dropdownItemText(label)));
  }

  // ordena por label (Text.data contiene el string cuando se usa constructor posicional)
  items.sort((a, b) {
    final ta = _textDataFromDropdownChild(a.child);
    final tb = _textDataFromDropdownChild(b.child);
    return ta.compareTo(tb);
  });

  return items;
}

class _CatalogOption {
  const _CatalogOption({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final String value;
  final String label;
  final String? subtitle;
}

List<_CatalogOption> _personOptionsFromDrift(List<dynamic> list) {
  Map<String, dynamic> toMap(dynamic x) {
    try {
      final m = (x as dynamic).toJson();
      if (m is Map) return m.cast<String, dynamic>();
    } catch (_) {}
    return <String, dynamic>{};
  }

  final items = <_CatalogOption>[];
  for (final x in list) {
    final m = toMap(x);
    final id = '${m['id'] ?? ''}'.trim();
    final nombre = '${m['nombreCompleto'] ?? m['nombre_completo'] ?? ''}'
        .trim();
    if (id.isEmpty || nombre.isEmpty) continue;

    final dni = '${m['dni'] ?? ''}'.trim();
    final tipo =
        '${m['tipoDescripcion'] ?? m['tipo_descripcion'] ?? m['tipoCodigo'] ?? ''}'
            .trim();
    final subtitle = dni.isNotEmpty ? 'DNI: $dni' : tipo;

    items.add(_CatalogOption(value: id, label: nombre, subtitle: subtitle));
  }

  items.sort((a, b) {
    return a.label.compareTo(b.label);
  });

  return items;
}

List<_CatalogOption> _loteOptionsFromDrift(List<dynamic> list) {
  Map<String, dynamic> toMap(dynamic x) {
    try {
      final m = (x as dynamic).toJson();
      if (m is Map) return m.cast<String, dynamic>();
    } catch (_) {}
    return <String, dynamic>{};
  }

  final items = <_CatalogOption>[];
  for (final x in list) {
    final m = toMap(x);
    final id = '${m['idLote'] ?? m['loteId'] ?? m['id'] ?? ''}'.trim();
    final descripcion = '${m['descripcion'] ?? m['label'] ?? ''}'.trim();
    if (id.isEmpty || descripcion.isEmpty) continue;

    final codigo = '${m['codigoLote'] ?? ''}'.trim();
    final lote = '${m['lote'] ?? ''}'.trim();
    final subLote = '${m['subLote'] ?? ''}'.trim();
    final subtitleParts = <String>[
      if (codigo.isNotEmpty) codigo,
      if (lote.isNotEmpty) lote,
      if (subLote.isNotEmpty) subLote,
    ];

    items.add(
      _CatalogOption(
        value: id,
        label: descripcion,
        subtitle: subtitleParts.isEmpty ? null : subtitleParts.join(' • '),
      ),
    );
  }

  items.sort((a, b) => a.label.compareTo(b.label));
  return items;
}

List<_CatalogOption> _topicoEmpresaOptionsFromDrift(List<dynamic> list) {
  final items = <_CatalogOption>[];
  for (final x in list) {
    final m = _driftToMap(x);
    final id = '${m['idEmpresa'] ?? ''}'.trim();
    final razonSocial = '${m['razonSocial'] ?? ''}'.trim();
    if (id.isEmpty || razonSocial.isEmpty) continue;
    final ruc = '${m['ruc'] ?? ''}'.trim();
    items.add(
      _CatalogOption(
        value: id,
        label: razonSocial,
        subtitle: ruc.isEmpty ? null : 'RUC: $ruc',
      ),
    );
  }
  items.sort((a, b) => a.label.compareTo(b.label));
  return items;
}

List<_CatalogOption> _topicoConsultaOptionsFromDrift(List<dynamic> list) {
  final items = <_CatalogOption>[];
  for (final x in list) {
    final m = _driftToMap(x);
    final codigo = '${m['codigo'] ?? ''}'.trim();
    final descripcion = '${m['descripcion'] ?? ''}'.trim();
    if (codigo.isEmpty || descripcion.isEmpty) continue;
    final tipo = '${m['tipoAtencion'] ?? ''}'.trim();
    items.add(
      _CatalogOption(
        value: codigo,
        label: descripcion,
        subtitle: tipo.isEmpty ? null : tipo,
      ),
    );
  }
  items.sort((a, b) => a.label.compareTo(b.label));
  return items;
}

List<_CatalogOption> _topicoMedicamentoOptionsFromDrift(List<dynamic> list) {
  final items = <_CatalogOption>[];
  for (final x in list) {
    final m = _driftToMap(x);
    final codigo = '${m['codigo'] ?? ''}'.trim();
    final medicamento = '${m['medicamento'] ?? ''}'.trim();
    if (codigo.isEmpty || medicamento.isEmpty) continue;
    final presentacion = '${m['tipoPresentacion'] ?? ''}'.trim();
    final lugar = '${m['lugar'] ?? ''}'.trim();
    final subtitle = [
      if (presentacion.isNotEmpty) presentacion,
      if (lugar.isNotEmpty) lugar,
    ].join(' • ');
    items.add(
      _CatalogOption(
        value: codigo,
        label: medicamento,
        subtitle: subtitle.isEmpty ? null : subtitle,
      ),
    );
  }
  items.sort((a, b) => a.label.compareTo(b.label));
  return items;
}

class _TopicoMedicamentoEntry {
  const _TopicoMedicamentoEntry({
    required this.codigo,
    required this.medicamento,
    required this.cantidad,
    this.detalle,
  });

  final String codigo;
  final String medicamento;
  final int cantidad;
  final String? detalle;

  _TopicoMedicamentoEntry copyWith({int? cantidad}) {
    return _TopicoMedicamentoEntry(
      codigo: codigo,
      medicamento: medicamento,
      cantidad: cantidad ?? this.cantidad,
      detalle: detalle,
    );
  }
}

int _topicoMedicamentoCantidad(dynamic value) {
  if (value is num) return value.toInt() < 1 ? 1 : value.toInt();
  final parsed = int.tryParse('${value ?? ''}'.trim()) ?? 1;
  return parsed < 1 ? 1 : parsed;
}

List<_TopicoMedicamentoEntry> _topicoMedicamentoEntriesFromValue(
  dynamic value,
  List<_CatalogOption> options,
) {
  final byValue = {for (final option in options) option.value: option};
  final entries = <_TopicoMedicamentoEntry>[];

  void appendEntry({
    required String codigo,
    required String medicamento,
    required int cantidad,
    String? detalle,
  }) {
    var normalizedCodigo = codigo.trim();
    final normalizedMedicamento = medicamento.trim();
    if (normalizedCodigo.isEmpty && normalizedMedicamento.isEmpty) return;
    if (normalizedCodigo.isEmpty) normalizedCodigo = normalizedMedicamento;

    final option = byValue[normalizedCodigo];
    final label = (option?.label.trim().isNotEmpty ?? false)
        ? option!.label.trim()
        : (normalizedMedicamento.isNotEmpty
              ? normalizedMedicamento
              : normalizedCodigo);
    final subtitle = (option?.subtitle?.trim().isNotEmpty ?? false)
        ? option!.subtitle!.trim()
        : detalle?.trim();

    final idx = entries.indexWhere((e) => e.codigo == normalizedCodigo);
    if (idx >= 0) {
      final current = entries[idx];
      entries[idx] = current.copyWith(
        cantidad: current.cantidad + (cantidad < 1 ? 1 : cantidad),
      );
      return;
    }

    entries.add(
      _TopicoMedicamentoEntry(
        codigo: normalizedCodigo,
        medicamento: label,
        cantidad: cantidad < 1 ? 1 : cantidad,
        detalle: subtitle?.isEmpty ?? true ? null : subtitle,
      ),
    );
  }

  if (value is Iterable && value is! String) {
    for (final item in value) {
      if (item is Map) {
        appendEntry(
          codigo: '${item['codigo'] ?? item['value'] ?? item['id'] ?? ''}'
              .trim(),
          medicamento:
              '${item['medicamento'] ?? item['label'] ?? item['nombre'] ?? ''}'
                  .trim(),
          cantidad: _topicoMedicamentoCantidad(item['cantidad']),
          detalle: '${item['detalle'] ?? item['presentacion'] ?? ''}'.trim(),
        );
      } else {
        final text = '${item ?? ''}'.trim();
        appendEntry(codigo: text, medicamento: text, cantidad: 1);
      }
    }
    return entries;
  }

  final text = '${value ?? ''}'.trim();
  if (text.isNotEmpty && text != '0') {
    appendEntry(codigo: text, medicamento: text, cantidad: 1);
  }
  return entries;
}

List<Map<String, dynamic>> _topicoMedicamentoEntriesToPayload(
  List<_TopicoMedicamentoEntry> entries,
) {
  return entries
      .map(
        (entry) => <String, dynamic>{
          'codigo': entry.codigo,
          'medicamento': entry.medicamento,
          'cantidad': entry.cantidad,
          if ((entry.detalle ?? '').trim().isNotEmpty)
            'detalle': entry.detalle!.trim(),
        },
      )
      .toList();
}

Map<String, dynamic> _driftToMap(dynamic x) {
  if (x is Map) return x.cast<String, dynamic>();
  try {
    final m = (x as dynamic).toJson();
    if (m is Map) return m.cast<String, dynamic>();
  } catch (_) {}
  return <String, dynamic>{};
}

String? _topicoPacienteNullableText(dynamic source, List<String> keys) {
  if (source == null) return null;
  final map = _driftToMap(source);
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  for (final key in keys) {
    final value = _topicoPacienteDirectValue(source, key);
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

String _topicoPacienteText(dynamic source, List<String> keys) {
  return _topicoPacienteNullableText(source, keys) ?? '';
}

String? _topicoPacienteGeneroLabel(dynamic source) {
  final raw = _topicoPacienteNullableText(source, const ['genero', 'SEXO']);
  if (raw == null) return null;
  final normalized = raw.trim().toUpperCase();
  if (normalized == 'F') return 'Femenino';
  if (normalized == 'M') return 'Masculino';
  return raw.trim();
}

dynamic _topicoPacienteDirectValue(dynamic source, String key) {
  try {
    switch (key) {
      case 'idCodigoGeneral':
        return (source as dynamic).idCodigoGeneral;
      case 'dni':
        return (source as dynamic).dni;
      case 'nombreCompleto':
        return (source as dynamic).nombreCompleto;
      case 'genero':
        return (source as dynamic).genero;
      case 'planilla':
        return (source as dynamic).planilla;
      case 'cargo':
        return (source as dynamic).cargo;
      case 'area':
        return (source as dynamic).area;
    }
  } catch (_) {}
  return null;
}

List<DropdownMenuEntry<String>> _personMenuEntries(
  List<_CatalogOption> options,
) {
  return options
      .map(
        (option) => DropdownMenuEntry<String>(
          value: option.value,
          label: option.label,
          labelWidget: _dropdownItemWithSubtitle(
            option.label,
            subtitle: option.subtitle,
          ),
        ),
      )
      .toList();
}

Widget _searchableCatalogField({
  required String label,
  required List<_CatalogOption> options,
  required String? value,
  required bool enabled,
  String? helperText,
  required ValueChanged<String?> onChanged,
}) {
  _CatalogOption? selected;
  for (final option in options) {
    if (option.value == value) {
      selected = option;
      break;
    }
  }

  final entries = _personMenuEntries(options);
  final byValue = {for (final option in options) option.value: option};

  return DropdownMenu<String>(
    key: ValueKey('person-dropdown-$label-$value-${options.length}'),
    enabled: enabled,
    initialSelection: selected?.value,
    enableFilter: true,
    enableSearch: true,
    requestFocusOnTap: true,
    expandedInsets: EdgeInsets.zero,
    menuHeight: 320,
    hintText: 'Buscar o seleccionar',
    helperText: helperText,
    label: Text(label),
    leadingIcon: const Icon(Icons.search),
    dropdownMenuEntries: entries,
    filterCallback: (entries, filter) {
      final q = filter.trim().toLowerCase();
      if (q.isEmpty) {
        return entries;
      }
      return entries.where((entry) {
        final option = byValue[entry.value];
        final haystack = '${entry.label} ${option?.subtitle ?? ''}'
            .toLowerCase();
        return haystack.contains(q);
      }).toList();
    },
    onSelected: onChanged,
  );
}

Widget _searchableDriftCatalogField({
  required String controlKey,
  required String label,
  required List<_CatalogOption> options,
  required String? value,
  required bool enabled,
  String? helperText,
  String hintText = 'Buscar o seleccionar',
  IconData leadingIcon = Icons.search,
  ValueChanged<String?>? onChanged,
}) {
  _CatalogOption? selected;
  for (final option in options) {
    if (option.value == value) {
      selected = option;
      break;
    }
  }

  final entries = _personMenuEntries(options);
  final byValue = {for (final option in options) option.value: option};

  return DropdownMenu<String>(
    key: ValueKey('$controlKey-$value-${options.length}'),
    enabled: enabled,
    initialSelection: selected?.value,
    enableFilter: true,
    enableSearch: true,
    requestFocusOnTap: true,
    expandedInsets: EdgeInsets.zero,
    menuHeight: 320,
    hintText: hintText,
    helperText: helperText,
    label: Text(label),
    leadingIcon: Icon(leadingIcon),
    dropdownMenuEntries: entries,
    filterCallback: (entries, filter) {
      final q = filter.trim().toLowerCase();
      if (q.isEmpty) return entries;
      return entries.where((entry) {
        final option = byValue[entry.value];
        final haystack = '${entry.label} ${option?.subtitle ?? ''}'
            .toLowerCase();
        return haystack.contains(q);
      }).toList();
    },
    onSelected: onChanged,
  );
}

class _TopicoMedicamentosField extends StatefulWidget {
  const _TopicoMedicamentosField({
    required this.label,
    required this.options,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.helperText,
  });

  final String label;
  final List<_CatalogOption> options;
  final dynamic value;
  final bool enabled;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;
  final String? helperText;

  @override
  State<_TopicoMedicamentosField> createState() =>
      _TopicoMedicamentosFieldState();
}

class _TopicoMedicamentosFieldState extends State<_TopicoMedicamentosField> {
  late List<_TopicoMedicamentoEntry> _entries;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _entries = _topicoMedicamentoEntriesFromValue(widget.value, widget.options);
  }

  @override
  void didUpdateWidget(covariant _TopicoMedicamentosField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.options != widget.options) {
      _entries = _topicoMedicamentoEntriesFromValue(
        widget.value,
        widget.options,
      );
      if (_selectedValue != null &&
          !widget.options.any((option) => option.value == _selectedValue)) {
        _selectedValue = null;
      }
    }
  }

  void _emit(List<_TopicoMedicamentoEntry> next) {
    setState(() => _entries = List<_TopicoMedicamentoEntry>.from(next));
    widget.onChanged(_topicoMedicamentoEntriesToPayload(_entries));
  }

  void _addSelected() {
    final selected = _selectedValue;
    if (selected == null || selected.trim().isEmpty) return;
    _CatalogOption? option;
    for (final item in widget.options) {
      if (item.value == selected) {
        option = item;
        break;
      }
    }
    if (option == null) return;
    final selectedOption = option;

    final next = List<_TopicoMedicamentoEntry>.from(_entries);
    final idx = next.indexWhere(
      (entry) => entry.codigo == selectedOption.value,
    );
    if (idx >= 0) {
      next[idx] = next[idx].copyWith(cantidad: next[idx].cantidad + 1);
    } else {
      next.add(
        _TopicoMedicamentoEntry(
          codigo: selectedOption.value,
          medicamento: selectedOption.label,
          cantidad: 1,
          detalle: selectedOption.subtitle,
        ),
      );
    }

    setState(() => _selectedValue = null);
    _emit(next);
  }

  void _changeQuantity(int index, int delta) {
    if (index < 0 || index >= _entries.length) return;
    final current = _entries[index];
    final nextQuantity = current.cantidad + delta;
    final next = List<_TopicoMedicamentoEntry>.from(_entries);
    if (nextQuantity < 1) {
      next.removeAt(index);
    } else {
      next[index] = current.copyWith(cantidad: nextQuantity);
    }
    _emit(next);
  }

  void _removeAt(int index) {
    if (index < 0 || index >= _entries.length) return;
    final next = List<_TopicoMedicamentoEntry>.from(_entries)..removeAt(index);
    _emit(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = widget.enabled && widget.options.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _searchableDriftCatalogField(
                controlKey: 'topico-medicamentos-picker',
                label: widget.label,
                options: widget.options,
                value: _selectedValue,
                helperText: widget.helperText,
                hintText: 'Buscar medicamento',
                leadingIcon: Icons.medication_outlined,
                enabled: enabled,
                onChanged: (value) => setState(() => _selectedValue = value),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: IconButton.filledTonal(
                tooltip: 'Agregar medicamento',
                onPressed: enabled && _selectedValue != null
                    ? _addSelected
                    : null,
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_entries.isEmpty)
          Text(
            'Sin medicamentos agregados',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _entries.length; i++)
                  _TopicoMedicamentoRow(
                    entry: _entries[i],
                    showDivider: i < _entries.length - 1,
                    enabled: widget.enabled,
                    onIncrement: () => _changeQuantity(i, 1),
                    onDecrement: () => _changeQuantity(i, -1),
                    onRemove: () => _removeAt(i),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TopicoMedicamentoRow extends StatelessWidget {
  const _TopicoMedicamentoRow({
    required this.entry,
    required this.showDivider,
    required this.enabled,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final _TopicoMedicamentoEntry entry;
  final bool showDivider;
  final bool enabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.medicamento,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if ((entry.detalle ?? '').trim().isNotEmpty)
                    Text(
                      entry.detalle!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Disminuir',
              onPressed: enabled ? onDecrement : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 34,
              child: Text(
                '${entry.cantidad}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Incrementar',
              onPressed: enabled ? onIncrement : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
            IconButton(
              tooltip: 'Quitar',
              onPressed: enabled ? onRemove : null,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicoPacienteSearchField extends ConsumerStatefulWidget {
  final String controlKey;
  final String label;
  final String? value;
  final String? initialText;
  final bool enabled;
  final ValueChanged<dynamic>? onSelected;

  const _TopicoPacienteSearchField({
    required this.controlKey,
    required this.label,
    required this.value,
    required this.initialText,
    required this.enabled,
    required this.onSelected,
  });

  @override
  ConsumerState<_TopicoPacienteSearchField> createState() =>
      _TopicoPacienteSearchFieldState();
}

class _TopicoPacienteSearchFieldState
    extends ConsumerState<_TopicoPacienteSearchField> {
  static const int _minChars = 3;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;
  Timer? _hideResultsTimer;
  String _query = '';
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    _focusNode = FocusNode()
      ..addListener(() {
        _hideResultsTimer?.cancel();
        if (!mounted) return;
        if (_focusNode.hasFocus) {
          setState(() => _showResults = _focusNode.hasFocus);
        } else {
          _hideResultsTimer = Timer(const Duration(milliseconds: 180), () {
            if (mounted) setState(() => _showResults = false);
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant _TopicoPacienteSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _controller.text = widget.initialText ?? '';
      _query = '';
      _showResults = false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideResultsTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scheduleSearch(String raw) {
    _debounce?.cancel();
    final text = raw.trim();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _query = text.length >= _minChars ? text : '';
        _showResults = _focusNode.hasFocus;
      });
    });
  }

  void _pick(dynamic item) {
    final nombre = _topicoPacienteText(item, const [
      'nombreCompleto',
      'nombre_completo',
      'NOMBRE_COMPLETO',
    ]);
    _debounce?.cancel();
    _hideResultsTimer?.cancel();
    setState(() {
      _controller.text = nombre;
      _query = '';
      _showResults = false;
    });
    _focusNode.unfocus();
    widget.onSelected?.call(item);
  }

  void _clear() {
    _debounce?.cancel();
    setState(() {
      _controller.clear();
      _query = '';
      _showResults = false;
    });
    widget.onSelected?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final canSearch = _query.length >= _minChars;
    final resultsAsync = canSearch
        ? ref.watch(topicoPacientesSearchProvider(_query))
        : const AsyncValue<List<dynamic>>.data(<dynamic>[]);

    final helper = !widget.enabled
        ? null
        : 'Ingrese minimo $_minChars caracteres';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: ValueKey(widget.controlKey),
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'Buscar por DNI o nombre',
            helperText: helper,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isEmpty || !widget.enabled
                ? null
                : IconButton(
                    tooltip: 'Limpiar',
                    icon: const Icon(Icons.close),
                    onPressed: _clear,
                  ),
          ),
          onChanged: (value) {
            setState(() => _showResults = _focusNode.hasFocus);
            _scheduleSearch(value);
          },
          onTap: () => setState(() => _showResults = true),
        ),
        if (widget.enabled && _showResults)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _TopicoPacienteResults(
              query: _query,
              minChars: _minChars,
              resultsAsync: resultsAsync,
              onSelected: _pick,
            ),
          ),
      ],
    );
  }
}

class _TopicoPacienteResults extends StatelessWidget {
  final String query;
  final int minChars;
  final AsyncValue<List<dynamic>> resultsAsync;
  final ValueChanged<dynamic> onSelected;

  const _TopicoPacienteResults({
    required this.query,
    required this.minChars,
    required this.resultsAsync,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (query.length < minChars) {
      return _TopicoPacienteResultBox(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Ingrese minimo $minChars caracteres para buscar'),
        ),
      );
    }

    return resultsAsync.when(
      loading: () => const _TopicoPacienteResultBox(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => const _TopicoPacienteResultBox(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Error buscando pacientes'),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _TopicoPacienteResultBox(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('Sin coincidencias'),
            ),
          );
        }

        return _TopicoPacienteResultBox(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final nombre = _topicoPacienteText(item, const [
                  'nombreCompleto',
                  'nombre_completo',
                  'NOMBRE_COMPLETO',
                ]);
                final dni = _topicoPacienteText(item, const ['dni', 'DNI']);
                final genero = _topicoPacienteGeneroLabel(item);
                final cargo = _topicoPacienteText(item, const [
                  'cargo',
                  'CARGO',
                ]);
                final subtitle = [
                  if (dni.isNotEmpty) 'DNI: $dni',
                  if (genero != null && genero.isNotEmpty) genero,
                  if (cargo.isNotEmpty) cargo,
                ].join(' • ');

                return ListTile(
                  dense: true,
                  title: Text(
                    nombre.isEmpty ? 'Sin nombre' : nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: subtitle.isEmpty
                      ? null
                      : Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                  onTap: () => onSelected(item),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TopicoPacienteResultBox extends StatelessWidget {
  final Widget child;

  const _TopicoPacienteResultBox({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// Entrada decimal en una sola línea: dígitos y un separador (`,` o `.`).
class _DecimalTextInputFormatter extends TextInputFormatter {
  const _DecimalTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final t = newValue.text.replaceAll(',', '.');
    if (t.isEmpty) return newValue;
    if (t == '.') return newValue;
    if (RegExp(r'^\d*\.?\d*$').hasMatch(t)) {
      return newValue;
    }
    return oldValue;
  }
}

final Set<String> _comparativeSeededForms = <String>{};
final Set<int> _podaFinalSeededForms = <int>{};

String _comparativeSeedKey(int localId, int? referenceLocalId) =>
    '$localId::$referenceLocalId';

dynamic _cloneReferenceValue(dynamic value) {
  if (value is List) {
    return value.map(_cloneReferenceValue).toList();
  }
  if (value is Map) {
    return value.map((key, val) => MapEntry('$key', _cloneReferenceValue(val)));
  }
  return value;
}

bool _isComparativeTechnicalField(CartillaFieldConfig field) {
  const technicalKeys = <String>{
    'plantillaId',
    'userId',
    'serverId',
    'localId',
    'lat',
    'lon',
    'fechaEjecucion',
    'syncStatus',
    'syncError',
    'syncAttempts',
  };

  if (field.type == CartillaFieldType.photo ||
      field.type == CartillaFieldType.signaturePad ||
      field.type == CartillaFieldType.intReadOnly ||
      field.type == CartillaFieldType.decimalReadOnly) {
    return true;
  }

  if (technicalKeys.contains(field.key)) return true;
  if (field.key == 'fotos') return true;
  if (field.key.startsWith('foto')) return true;
  return false;
}

bool _hasReferenceValue(dynamic value) {
  if (value == null) return false;
  if (value is String) return value.trim().isNotEmpty;
  if (value is Iterable) return value.isNotEmpty;
  if (value is Map) return value.isNotEmpty;
  return true;
}

String _referenceDisplayValue(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is num || value is bool) return '$value';
  if (value is List) return value.map((e) => '$e').join(', ');
  if (value is Map) {
    return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
  return value.toString();
}

String _comparableValue(dynamic value) {
  if (value == null) return '';
  if (value is num || value is bool) return '$value';
  if (value is String) return value.trim();
  if (value is List) return value.map(_comparableValue).join('|');
  if (value is Map) {
    final keys = value.keys.map((e) => '$e').toList()..sort();
    return keys.map((k) => '$k=${_comparableValue(value[k])}').join('|');
  }
  return value.toString().trim();
}

bool _hasEditedComparativeValue(dynamic value) {
  if (value == null) return false;
  if (value is String) return value.trim().isNotEmpty;
  if (value is Iterable) return value.isNotEmpty;
  if (value is Map) return value.isNotEmpty;
  return true;
}

dynamic _seedComparativePayload({
  required CartillaFormConfig config,
  required dynamic currentPayload,
  required Map<String, dynamic> referenceHeader,
  required Map<String, dynamic> referenceBody,
}) {
  var nextPayload = currentPayload;
  final seededKeys = <String>{};

  for (final section in config.sections) {
    for (final field in section.fields) {
      if (_isComparativeTechnicalField(field)) continue;
      if (!seededKeys.add(field.key)) continue;

      final referenceValue = config.headerKeys.contains(field.key)
          ? referenceHeader[field.key]
          : referenceBody[field.key];

      if (!_hasReferenceValue(referenceValue)) continue;

      nextPayload = config.headerKeys.contains(field.key)
          ? (nextPayload as dynamic).setHeaderValue(field.key, referenceValue)
          : (nextPayload as dynamic).setBodyValue(field.key, referenceValue);
    }
  }

  return nextPayload;
}

bool _podaNeedsFinalSeed(dynamic payload) {
  for (final key in CartillaPodaConfig.comparativeBodyKeys) {
    final sourceValue = (payload as dynamic).getBodyValue(key);
    if (!_hasReferenceValue(sourceValue)) continue;

    final finalValue = (payload as dynamic).getBodyValue(
      CartillaPodaConfig.finalBodyKey(key),
    );
    if (!_hasReferenceValue(finalValue)) return true;
  }

  final fotos = (payload as dynamic).getBodyValue('fotos');
  final finalFotos = (payload as dynamic).getBodyValue(
    CartillaPodaConfig.kFinalFotos,
  );
  return _hasReferenceValue(fotos) && !_hasReferenceValue(finalFotos);
}

dynamic _seedPodaFinalPayload(dynamic currentPayload) {
  var nextPayload = currentPayload;

  for (final key in CartillaPodaConfig.comparativeBodyKeys) {
    final sourceValue = (currentPayload as dynamic).getBodyValue(key);
    if (!_hasReferenceValue(sourceValue)) continue;
    final finalKey = CartillaPodaConfig.finalBodyKey(key);
    final existingFinalValue = (currentPayload as dynamic).getBodyValue(
      finalKey,
    );
    if (_hasReferenceValue(existingFinalValue)) continue;

    nextPayload = (nextPayload as dynamic).setBodyValue(
      finalKey,
      _cloneReferenceValue(sourceValue),
    );
  }

  final fotos = (currentPayload as dynamic).getBodyValue('fotos');
  final finalFotos = (currentPayload as dynamic).getBodyValue(
    CartillaPodaConfig.kFinalFotos,
  );
  if (_hasReferenceValue(fotos) && !_hasReferenceValue(finalFotos)) {
    nextPayload = (nextPayload as dynamic).setBodyValue(
      CartillaPodaConfig.kFinalFotos,
      _cloneReferenceValue(fotos),
    );
  }

  return nextPayload;
}

Widget _referenceValueBox({required String value, required bool modified}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: DonLuisColors.primary.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: DonLuisColors.primary.withValues(alpha: 0.28),
        width: 1.2,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 34,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: DonLuisColors.primary.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DATO INICIAL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: DonLuisColors.primary.withValues(alpha: 0.88),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D21),
                ),
              ),
            ],
          ),
        ),
        if (modified) ...[
          const SizedBox(width: 8),
          Chip(
            label: const Text('Modificado'),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            backgroundColor: DonLuisColors.accent.withValues(alpha: 0.18),
            side: BorderSide(
              color: DonLuisColors.accent.withValues(alpha: 0.55),
            ),
            labelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A5A00),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _wrapFieldWithReference({
  required CartillaFieldConfig field,
  required bool comparativeMode,
  required bool fieldReadOnly,
  required dynamic currentValue,
  required Widget child,
  dynamic Function(String)? getReferenceBodyValue,
  dynamic Function(String)? getReferenceHeaderValue,
}) {
  if (!comparativeMode ||
      fieldReadOnly ||
      _isComparativeTechnicalField(field)) {
    return child;
  }

  final referenceValue =
      getReferenceHeaderValue != null || getReferenceBodyValue != null
      ? (getReferenceHeaderValue?.call(field.key) ??
            getReferenceBodyValue?.call(field.key))
      : null;

  if (!_hasReferenceValue(referenceValue)) return child;

  final initialText = _referenceDisplayValue(referenceValue);
  if (initialText.isEmpty) return child;

  final modified =
      _hasEditedComparativeValue(currentValue) &&
      _comparableValue(currentValue) != _comparableValue(referenceValue);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _referenceValueBox(value: initialText, modified: modified),
      child,
    ],
  );
}

class CartillaFormPage extends ConsumerStatefulWidget {
  final int localId;
  final CartillaFormConfig config;
  final int? referenceLocalId;
  final bool comparativeMode;
  final bool podaFinalMode;

  const CartillaFormPage({
    super.key,
    required this.localId,
    required this.config,
    this.referenceLocalId,
    this.comparativeMode = false,
    this.podaFinalMode = false,
  });

  @override
  ConsumerState<CartillaFormPage> createState() => _CartillaFormPageState();
}

class _CartillaFormPageState extends ConsumerState<CartillaFormPage> {
  late final ValueNotifier<_GpsIndicatorState> _gpsIndicator;
  StreamSubscription<Map<String, dynamic>>? _gpsIndicatorSub;
  Timer? _gpsIndicatorTimer;

  @override
  void initState() {
    super.initState();
    _gpsIndicator = ValueNotifier<_GpsIndicatorState>(
      const _GpsIndicatorState(),
    );
    final locationService = ref.read(locationServiceProvider);
    locationService.startForegroundWarmup();
    _gpsIndicatorSub = locationService
        .watchPositionStream(distanceFilter: 0)
        .listen(
          (geo) {
            if (!mounted) return;
            final lat = (geo['lat'] as num?)?.toDouble();
            final lon = (geo['lon'] as num?)?.toDouble();
            if (lat == null || lon == null) return;
            _gpsIndicator.value = _GpsIndicatorState(
              lat: lat,
              lon: lon,
              accuracyMeters: (geo['gpsAccuracy'] as num?)?.toDouble(),
              updatedAt: _gpsDateFromGeo(geo) ?? DateTime.now(),
              searching: false,
            );
          },
          onError: (_) {
            _gpsIndicator.value = const _GpsIndicatorState(searching: false);
          },
        );
    _gpsIndicatorTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_gpsIndicator.value.hasFix) return;
      _gpsIndicator.value = _gpsIndicator.value.copyWith();
    });
  }

  @override
  void dispose() {
    _gpsIndicatorTimer?.cancel();
    _gpsIndicatorSub?.cancel();
    _gpsIndicator.dispose();
    ref.read(locationServiceProvider).stopForegroundWarmup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localId = widget.localId;
    final config = widget.config;
    final referenceLocalId = widget.referenceLocalId;
    final comparativeMode = widget.comparativeMode;
    final podaFinalMode = widget.podaFinalMode;

    final binding = CartillaRegistry.resolveBinding(config.templateKey);
    final isPoda = config.templateKey == CartillaPodaConfig.templateKeyStatic;
    final usePodaFinalMode = isPoda && podaFinalMode;

    final st = binding.watchState(ref, localId);
    final nt = binding.readNotifier(ref, localId);
    final payload = st.payload;

    final photoService = ref.read(photoServiceProvider);

    final registroAsync = ref.watch(registroByLocalIdProvider(localId));
    final referenceRegistroAsync = comparativeMode && referenceLocalId != null
        ? ref.watch(registroByLocalIdProvider(referenceLocalId))
        : const AsyncValue<Registro?>.data(null);
    // Consideramos \"sincronizado\" si ya tiene serverId asignado.
    final isSyncedRecord = registroAsync.maybeWhen(
      data: (reg) => reg.serverId != null,
      orElse: () => false,
    );

    if (st.loading == true) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    dynamic getHeaderValue(String key) {
      return (st.payload as dynamic).getHeaderValue(key);
    }

    void setHeaderValue(String key, dynamic value) {
      if (getHeaderValue(key) == value) return;
      final nextPayload = (st.payload as dynamic).setHeaderValue(key, value);
      nt.update(nextPayload);
    }

    dynamic getBodyValue(String key) {
      return (st.payload as dynamic).getBodyValue(key);
    }

    void setBodyValue(String key, dynamic value) {
      if (getBodyValue(key) == value) return;
      final nextPayload = (st.payload as dynamic).setBodyValue(key, value);
      nt.update(nextPayload);
    }

    void setBodyValues(Map<String, dynamic> values) {
      dynamic nextPayload = (nt as dynamic).state.payload;
      for (final entry in values.entries) {
        nextPayload = (nextPayload as dynamic).setBodyValue(
          entry.key,
          entry.value,
        );
      }
      (nt as dynamic).update(nextPayload);
    }

    int getBodyInt(String key) {
      return (st.payload as dynamic).getBodyInt(key, fallback: 0);
    }

    int getPodaBodyInt(String key) {
      return (st.payload as dynamic).getBodyInt(key, fallback: 0);
    }

    dynamic getValidationBodyValue(String key) {
      if (usePodaFinalMode && CartillaPodaConfig.isComparativeBodyKey(key)) {
        return getBodyValue(CartillaPodaConfig.finalBodyKey(key));
      }
      return getBodyValue(key);
    }

    final referencePayload = referenceRegistroAsync.maybeWhen(
      data: (reg) => reg?.normalizedPayload(),
      orElse: () => null,
    );

    dynamic getReferenceHeaderValue(String key) {
      final header = referencePayload?['header'];
      if (header is Map<String, dynamic>) return header[key];
      if (header is Map) return header[key];
      return null;
    }

    dynamic getReferenceBodyValue(String key) {
      final body = referencePayload?['body'];
      if (body is Map<String, dynamic>) return body[key];
      if (body is Map) return body[key];
      return null;
    }

    final shouldSeedComparativePayload =
        comparativeMode &&
        referenceLocalId != null &&
        referenceLocalId != localId &&
        referencePayload != null &&
        !_comparativeSeededForms.contains(
          _comparativeSeedKey(localId, referenceLocalId),
        );

    if (shouldSeedComparativePayload) {
      final refHeader = Map<String, dynamic>.from(
        (referencePayload['header'] as Map?)?.cast<String, dynamic>() ??
            const {},
      );
      final refBody = Map<String, dynamic>.from(
        (referencePayload['body'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
      final seedKey = _comparativeSeedKey(localId, referenceLocalId);
      final nextPayload = _seedComparativePayload(
        config: config,
        currentPayload: st.payload,
        referenceHeader: refHeader,
        referenceBody: refBody,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_comparativeSeededForms.contains(seedKey)) return;
        _comparativeSeededForms.add(seedKey);
        (nt as dynamic).update(nextPayload);
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final shouldSeedPodaFinalPayload =
        usePodaFinalMode &&
        _podaNeedsFinalSeed(st.payload) &&
        !_podaFinalSeededForms.contains(localId);

    if (shouldSeedPodaFinalPayload) {
      final nextPayload = _seedPodaFinalPayload(st.payload);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_podaFinalSeededForms.contains(localId)) return;
        _podaFinalSeededForms.add(localId);
        (nt as dynamic).update(nextPayload);
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DonLuisGradientScaffold(
      appBar: DonLuisAppBar(
        title: Text(
          usePodaFinalMode
              ? '${config.templateKey} · final'
              : config.templateKey,
        ),
        actions: [
          // 💾 GUARDAR (valida + listo para sincronizar)
          IconButton(
            tooltip: 'Guardar (listo para sincronizar)',
            onPressed: st.saving == true || isSyncedRecord
                ? null
                : () async {
                    final issues = [
                      ...validateRequired(
                        config: config,
                        getHeaderValue: (k) => payload.getHeaderValue(k),
                        getBodyValue: getValidationBodyValue,
                      ),
                      ..._validateSupervisionSalidaIssues(
                        config: config,
                        getBodyValue: getBodyValue,
                      ),
                    ];

                    if (issues.isNotEmpty) {
                      await showValidationDialog(context, issues);
                      return;
                    }

                    debugPrint(
                      '🟩 BEFORE save header.campaniaId=${getHeaderValue('campaniaId')}',
                    );
                    debugPrint(
                      '🟩 BEFORE save header.loteId=${getHeaderValue('loteId')}',
                    );

                    // 1) Guardar usando la lógica específica de la cartilla
                    await nt.saveLocal();

                    // 2) Marcar listo para sincronizar (estado=listo, syncStatus=pending)
                    final local = ref.read(registrosLocalDSProvider);
                    await local.markAsReadyForSync(localId);

                    debugPrint('🟩 AFTER save+markAsReady (ready for sync)');

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Guardado y listo para sincronizar'),
                        ),
                      );
                    }
                  },
            icon: st.saving == true
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),

          // ➕ +1 (duplicar)
          IconButton(
            tooltip: '+1',
            onPressed: st.saving == true || usePodaFinalMode
                ? null
                : () async {
                    await nt.saveLocal();
                    final newLocalId = await nt.duplicateAsNew();
                    // Nuevo registro también queda listo para sincronizar
                    final local = ref.read(registrosLocalDSProvider);
                    await local.markAsReadyForSync(newLocalId);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => CartillaFormPage(
                            key: ValueKey<int>(newLocalId),
                            localId: newLocalId,
                            config: config,
                          ),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Duplicado (+1)')),
                      );
                    }
                  },
            icon: const Icon(Icons.exposure_plus_1),
          ),
        ],
      ),
      body: Column(
        children: [
          _gpsIndicatorBar(listenable: _gpsIndicator),
          Expanded(
            child:
                config.templateKey ==
                    CartillaSupervisionLaborConfig.templateKeyStatic
                ? _buildSupervisionLaborBody(
                    context: context,
                    ref: ref,
                    config: config,
                    localId: localId,
                    photoService: photoService,
                    currentPayload: st.payload,
                    commitPayload: (dynamic p) => (nt as dynamic).update(p),
                    getHeaderValue: getHeaderValue,
                    setHeaderValue: setHeaderValue,
                    getBodyValue: getBodyValue,
                    getBodyInt: getBodyInt,
                    setBodyValue: setBodyValue,
                    setBodyValues: setBodyValues,
                    readOnly: isSyncedRecord,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount: config.sections.length,
                    itemBuilder: (_, idx) {
                      final section = config.sections[idx];
                      return DonLuisSectionCard(
                        key: ValueKey<String>(
                          'cartilla-$localId-${section.key}',
                        ),
                        title: section.title,
                        icon: Icons.folder_outlined,
                        initiallyExpanded: section.initiallyExpanded,
                        child: Column(
                          children: [
                            for (final field in section.fields)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _renderField(
                                  context: context,
                                  ref: ref,
                                  field: field,
                                  config: config,
                                  localId: localId,
                                  photoService: photoService,
                                  currentPayload: st.payload,
                                  commitPayload: (dynamic p) =>
                                      (nt as dynamic).update(p),
                                  getHeaderValue: getHeaderValue,
                                  setHeaderValue: setHeaderValue,
                                  getBodyValue:
                                      usePodaFinalMode &&
                                          CartillaPodaConfig.isComparativeSection(
                                            section.key,
                                          )
                                      ? (k) => getBodyValue(
                                          CartillaPodaConfig.finalBodyKey(k),
                                        )
                                      : getBodyValue,
                                  getBodyInt:
                                      usePodaFinalMode &&
                                          CartillaPodaConfig.isComparativeSection(
                                            section.key,
                                          )
                                      ? (k) => getPodaBodyInt(
                                          CartillaPodaConfig.finalBodyKey(k),
                                        )
                                      : getBodyInt,
                                  setBodyValue:
                                      usePodaFinalMode &&
                                          CartillaPodaConfig.isComparativeSection(
                                            section.key,
                                          )
                                      ? (k, v) => setBodyValue(
                                          CartillaPodaConfig.finalBodyKey(k),
                                          v,
                                        )
                                      : setBodyValue,
                                  setBodyValues: setBodyValues,
                                  getReferenceBodyValue:
                                      usePodaFinalMode &&
                                          CartillaPodaConfig.isComparativeSection(
                                            section.key,
                                          )
                                      ? getBodyValue
                                      : getReferenceBodyValue,
                                  getReferenceHeaderValue:
                                      getReferenceHeaderValue,
                                  comparativeMode: usePodaFinalMode
                                      ? CartillaPodaConfig.isComparativeSection(
                                          section.key,
                                        )
                                      : comparativeMode,
                                  photoListBodyKeyOverride:
                                      usePodaFinalMode &&
                                          section.key ==
                                              CartillaPodaConfig
                                                  .kSectionCalificacion
                                      ? CartillaPodaConfig.kFinalFotos
                                      : null,
                                  readOnly:
                                      isSyncedRecord ||
                                      (usePodaFinalMode &&
                                          !CartillaPodaConfig.isComparativeSection(
                                            section.key,
                                          )),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Barra inferior Guardar
          Container(
            decoration: BoxDecoration(
              color: DonLuisColors.surfaceCard,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: st.saving == true
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          st.saving == true ? 'Guardando...' : 'Guardar',
                        ),
                        onPressed: st.saving == true || isSyncedRecord
                            ? null
                            : () async {
                                final issues = [
                                  ...validateRequired(
                                    config: config,
                                    getHeaderValue: (k) =>
                                        payload.getHeaderValue(k),
                                    getBodyValue: getValidationBodyValue,
                                  ),
                                  ..._validateSupervisionSalidaIssues(
                                    config: config,
                                    getBodyValue: getBodyValue,
                                  ),
                                ];

                                if (issues.isNotEmpty) {
                                  await showValidationDialog(context, issues);
                                  return;
                                }

                                // 1) Guardar usando la lógica específica de la cartilla
                                await nt.saveLocal();

                                // 2) Marcar listo para sincronizar
                                final local = ref.read(
                                  registrosLocalDSProvider,
                                );
                                await local.markAsReadyForSync(localId);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Guardado y listo para sincronizar',
                                      ),
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSupervisionLaborBody({
  required BuildContext context,
  required WidgetRef ref,
  required CartillaFormConfig config,
  required int localId,
  required PhotoService photoService,
  required bool readOnly,
  required dynamic currentPayload,
  required void Function(dynamic nextPayload) commitPayload,
  required dynamic Function(String) getHeaderValue,
  required void Function(String, dynamic) setHeaderValue,
  required dynamic Function(String) getBodyValue,
  required int Function(String) getBodyInt,
  required void Function(String, dynamic) setBodyValue,
  required void Function(Map<String, dynamic>) setBodyValues,
}) {
  CartillaFieldConfig field(String key) {
    for (final section in config.sections) {
      for (final f in section.fields) {
        if (f.key == key) return f;
      }
    }
    throw StateError('Campo no encontrado: $key');
  }

  Widget render(CartillaFieldConfig field) {
    final nowPe = _nowPeru();
    final actividadLaboresAsync = ref.watch(actividadLaboresStreamProvider);
    final actividadLabores = actividadLaboresAsync.value ?? const [];

    if (field.key == CartillaSupervisionLaborConfig.kFecha) {
      return _supervisionDateField(
        context: context,
        label: field.label,
        value: getBodyValue(field.key),
        readOnly: readOnly,
        defaultValue: _formatDatePe(nowPe),
        onChanged: (value) => setBodyValue(field.key, value),
      );
    }

    if (field.key == CartillaSupervisionLaborConfig.kHoraInicio ||
        field.key == CartillaSupervisionLaborConfig.kHoraFinal) {
      return _supervisionTimeField(
        context: context,
        label: field.label,
        value: getBodyValue(field.key),
        readOnly: readOnly,
        defaultValue: _formatTimePe(nowPe),
        onChanged: (value) => setBodyValue(field.key, value),
      );
    }

    if (field.key == CartillaSupervisionLaborConfig.kActividadNombre) {
      return _supervisionActividadField(
        label: field.label,
        value: getBodyValue(CartillaSupervisionLaborConfig.kActividadId),
        actividadLabores: actividadLabores,
        readOnly: readOnly,
        onChanged: (option) {
          dynamic next = currentPayload;
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kActividadId,
            option?.actividadId,
          );
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kActividadNombre,
            option?.actividadNombre,
          );
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kLaborId,
            null,
          );
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kLaborNombre,
            null,
          );
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kLabor,
            null,
          );
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kCosto,
            null,
          );
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kRendimiento,
            null,
          );
          commitPayload(next);
        },
      );
    }

    if (field.key == CartillaSupervisionLaborConfig.kLabor) {
      return _supervisionLaborField(
        label: field.label,
        value:
            getBodyValue(CartillaSupervisionLaborConfig.kLaborId) ??
            getBodyValue(CartillaSupervisionLaborConfig.kLabor),
        actividadId: _textValue(
          getBodyValue(CartillaSupervisionLaborConfig.kActividadId),
        ),
        actividadLabores: actividadLabores,
        fallbackOptions: field.staticOptions ?? const [],
        readOnly: readOnly,
        onChanged: (option) {
          dynamic next = currentPayload;
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kLaborId,
            option?.laborId,
          );
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kLaborNombre,
            option?.laborNombre,
          );
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kLabor,
            option?.laborNombre,
          );
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kCosto,
            option?.costo,
          );
          next = (next as dynamic).setBodyValue(
            CartillaSupervisionLaborConfig.kRendimiento,
            option?.rendimiento,
          );
          commitPayload(next);
        },
      );
    }

    return _renderField(
      context: context,
      ref: ref,
      field: field,
      config: config,
      localId: localId,
      photoService: photoService,
      readOnly: readOnly,
      currentPayload: currentPayload,
      commitPayload: commitPayload,
      getHeaderValue: getHeaderValue,
      setHeaderValue: setHeaderValue,
      getBodyValue: getBodyValue,
      getBodyInt: getBodyInt,
      setBodyValue: setBodyValue,
      setBodyValues: setBodyValues,
    );
  }

  final visibleWorkers = _supervisionVisibleWorkers(getBodyValue);

  _ensureSupervisionDateTimeDefaults(
    getBodyValue: getBodyValue,
    setBodyValue: setBodyValue,
    readOnly: readOnly,
  );

  return ListView(
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
    children: [
      DonLuisSectionCard(
        title: 'CABECERA',
        icon: Icons.assignment_outlined,
        child: _supervisionResponsiveFields([
          field(CartillaSupervisionLaborConfig.kSupervisor),
          field(CartillaSupervisionLaborConfig.kSector),
          field(CartillaSupervisionLaborConfig.kHoraInicio),
          field(CartillaSupervisionLaborConfig.kHoraFinal),
          field(CartillaSupervisionLaborConfig.kFecha),
          field(CartillaSupervisionLaborConfig.kActividadNombre),
          field(CartillaSupervisionLaborConfig.kLabor),
          field(CartillaSupervisionLaborConfig.kCampaniaId),
          field(CartillaSupervisionLaborConfig.kLoteId),
          field(CartillaSupervisionLaborConfig.kCosto),
          field(CartillaSupervisionLaborConfig.kRendimiento),
        ], render),
      ),
      DonLuisSectionCard(
        title: 'TRABAJADORES',
        icon: Icons.groups_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 1; i <= visibleWorkers; i++) ...[
              _supervisionWorkerCard(
                context: context,
                index: i,
                readOnly: readOnly,
                getBodyValue: getBodyValue,
                setBodyValue: setBodyValue,
                setBodyValues: setBodyValues,
                onEdit: () => _showSupervisionWorkerSheet(
                  context: context,
                  ref: ref,
                  readOnly: readOnly,
                  getBodyValue: getBodyValue,
                  setBodyValue: setBodyValue,
                  workerIndex: i,
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (visibleWorkers < 6)
              OutlinedButton.icon(
                onPressed: readOnly
                    ? null
                    : () async {
                        final nextIndex = visibleWorkers + 1;
                        setBodyValue('trabajadoresVisibles', nextIndex);
                        await _showSupervisionWorkerSheet(
                          context: context,
                          ref: ref,
                          readOnly: readOnly,
                          getBodyValue: getBodyValue,
                          setBodyValue: setBodyValue,
                          workerIndex: nextIndex,
                        );
                      },
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Agregar trabajador'),
              ),
          ],
        ),
      ),
      DonLuisSectionCard(
        title: 'RESUMEN Y APROBACIÓN',
        icon: Icons.fact_check_outlined,
        child: Column(
          children: [
            _supervisionSummaryStrip(getBodyValue),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _signatureActionButton(
                    context: context,
                    label: 'V°B° Supervisor',
                    value: getBodyValue(
                      CartillaSupervisionLaborConfig.kFirmaSupervisor,
                    ),
                    readOnly: readOnly,
                    onChanged: (value) => setBodyValue(
                      CartillaSupervisionLaborConfig.kFirmaSupervisor,
                      value,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _signatureActionButton(
                    context: context,
                    label: 'V°B° Producción',
                    value: getBodyValue(
                      CartillaSupervisionLaborConfig.kFirmaProduccion,
                    ),
                    readOnly: readOnly,
                    onChanged: (value) => setBodyValue(
                      CartillaSupervisionLaborConfig.kFirmaProduccion,
                      value,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            render(field(CartillaSupervisionLaborConfig.kObservaciones)),
          ],
        ),
      ),
    ],
  );
}

List<ValidationIssue> _validateSupervisionSalidaIssues({
  required CartillaFormConfig config,
  required dynamic Function(String) getBodyValue,
}) {
  if (config.templateKey != CartillaSupervisionLaborConfig.templateKeyStatic) {
    return const [];
  }

  final issues = <ValidationIssue>[];
  for (var i = 1; i <= 6; i++) {
    final firma = getBodyValue(CartillaSupervisionLaborConfig.kFirmaSalida(i));
    if (!_hasSignature(firma)) continue;

    final hora = _textValue(
      getBodyValue(CartillaSupervisionLaborConfig.kHoraSalida(i)),
    );
    final motivo = _textValue(
      getBodyValue(CartillaSupervisionLaborConfig.kMotivoSalida(i)),
    );
    final observacion = _textValue(
      getBodyValue(CartillaSupervisionLaborConfig.kObservacionSalida(i)),
    );
    final sectionKey = 'trabajador_$i';
    final sectionTitle = 'TRABAJADOR $i';

    if (hora.isEmpty) {
      issues.add(
        ValidationIssue(
          sectionKey: sectionKey,
          sectionTitle: sectionTitle,
          fieldKey: CartillaSupervisionLaborConfig.kHoraSalida(i),
          fieldLabel: 'Hora de salida',
        ),
      );
    }
    if (motivo.isEmpty) {
      issues.add(
        ValidationIssue(
          sectionKey: sectionKey,
          sectionTitle: sectionTitle,
          fieldKey: CartillaSupervisionLaborConfig.kMotivoSalida(i),
          fieldLabel: 'Motivo de salida',
        ),
      );
    }
    final requiresObservation =
        motivo == 'NO CUMPLE.' || motivo == 'SALIDA POR SALUD.';
    if (requiresObservation && observacion.isEmpty) {
      issues.add(
        ValidationIssue(
          sectionKey: sectionKey,
          sectionTitle: sectionTitle,
          fieldKey: CartillaSupervisionLaborConfig.kObservacionSalida(i),
          fieldLabel: 'Observaciones de salida',
        ),
      );
    }
  }
  return issues;
}

class _SupervisionActividadOption {
  const _SupervisionActividadOption({
    required this.actividadId,
    required this.actividadNombre,
  });

  final String actividadId;
  final String actividadNombre;
}

class _SupervisionLaborOption {
  const _SupervisionLaborOption({
    required this.laborId,
    required this.laborNombre,
    this.actividadId,
    this.costo,
    this.rendimiento,
  });

  final String laborId;
  final String laborNombre;
  final String? actividadId;
  final double? costo;
  final double? rendimiento;
}

String _supervisionLaborLabel(_SupervisionLaborOption option) {
  if (option.laborId == option.laborNombre) return option.laborNombre;
  return '${option.laborId} - ${option.laborNombre}';
}

Map<String, dynamic> _actividadLaborMap(dynamic item) {
  try {
    final json = (item as dynamic).toJson();
    if (json is Map) return json.cast<String, dynamic>();
  } catch (_) {}
  return <String, dynamic>{};
}

String _catalogText(Map<String, dynamic> map, String key) {
  return '${map[key] ?? ''}'.trim();
}

double? _catalogDouble(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '.').trim());
}

List<_SupervisionActividadOption> _supervisionActividadOptions(
  List<dynamic> actividadLabores,
) {
  final byId = <String, _SupervisionActividadOption>{};
  for (final item in actividadLabores) {
    final map = _actividadLaborMap(item);
    final id = _catalogText(map, 'actividadId');
    final name = _catalogText(map, 'actividadNombre');
    if (id.isEmpty || name.isEmpty) continue;
    byId.putIfAbsent(
      id,
      () => _SupervisionActividadOption(actividadId: id, actividadNombre: name),
    );
  }
  final options = byId.values.toList()
    ..sort((a, b) => a.actividadNombre.compareTo(b.actividadNombre));
  return options;
}

List<_SupervisionLaborOption> _supervisionLaborOptions({
  required List<dynamic> actividadLabores,
  required String actividadId,
  required List<String> fallbackOptions,
}) {
  final options = <_SupervisionLaborOption>[];
  for (final item in actividadLabores) {
    final map = _actividadLaborMap(item);
    final itemActividadId = _catalogText(map, 'actividadId');
    if (actividadId.isNotEmpty && itemActividadId != actividadId) continue;

    final laborId = _catalogText(map, 'laborId');
    final laborNombre = _catalogText(map, 'laborNombre');
    if (laborId.isEmpty || laborNombre.isEmpty) continue;

    options.add(
      _SupervisionLaborOption(
        laborId: laborId,
        laborNombre: laborNombre,
        actividadId: itemActividadId,
        costo: _catalogDouble(map, 'costo'),
        rendimiento: _catalogDouble(map, 'rendimiento'),
      ),
    );
  }

  if (options.isEmpty) {
    return fallbackOptions
        .map(
          (label) =>
              _SupervisionLaborOption(laborId: label, laborNombre: label),
        )
        .toList(growable: false);
  }

  options.sort((a, b) => a.laborNombre.compareTo(b.laborNombre));
  return options;
}

Widget _supervisionActividadField({
  required String label,
  required dynamic value,
  required List<dynamic> actividadLabores,
  required bool readOnly,
  required ValueChanged<_SupervisionActividadOption?> onChanged,
}) {
  final options = _supervisionActividadOptions(actividadLabores);
  final valueText = _textValue(value);
  final selected = options.any((option) => option.actividadId == valueText)
      ? valueText
      : null;

  return DropdownButtonFormField<String>(
    isExpanded: true,
    value: selected,
    decoration: InputDecoration(
      labelText: label,
      helperText: options.isEmpty
          ? 'Sin catálogo sincronizado; seleccione la labor directamente'
          : null,
    ),
    items: [
      for (final option in options)
        DropdownMenuItem<String>(
          value: option.actividadId,
          child: _dropdownItemText(option.actividadNombre),
        ),
    ],
    onChanged: readOnly || options.isEmpty
        ? null
        : (nextId) {
            _SupervisionActividadOption? option;
            for (final item in options) {
              if (item.actividadId == nextId) {
                option = item;
                break;
              }
            }
            onChanged(option);
          },
  );
}

Widget _supervisionLaborField({
  required String label,
  required dynamic value,
  required String actividadId,
  required List<dynamic> actividadLabores,
  required List<String> fallbackOptions,
  required bool readOnly,
  required ValueChanged<_SupervisionLaborOption?> onChanged,
}) {
  final options = _supervisionLaborOptions(
    actividadLabores: actividadLabores,
    actividadId: actividadId,
    fallbackOptions: fallbackOptions,
  );
  final valueText = _textValue(value);
  _SupervisionLaborOption? selectedOption;
  for (final option in options) {
    if (option.laborId == valueText || option.laborNombre == valueText) {
      selectedOption = option;
      break;
    }
  }
  final selected = selectedOption?.laborId;
  final byValue = {for (final option in options) option.laborId: option};
  final disableUntilActividad =
      actividadLabores.isNotEmpty && actividadId.isEmpty;

  return DropdownMenu<String>(
    key: ValueKey('supervision-labor-$actividadId-$selected-${options.length}'),
    enabled: !readOnly && options.isNotEmpty && !disableUntilActividad,
    initialSelection: selected,
    enableFilter: true,
    enableSearch: true,
    requestFocusOnTap: true,
    expandedInsets: EdgeInsets.zero,
    menuHeight: 320,
    label: Text(label),
    hintText: 'Buscar por código o nombre',
    helperText: disableUntilActividad
        ? 'Seleccione primero el tipo de labor'
        : options.isEmpty
        ? 'Sin labores sincronizadas'
        : null,
    leadingIcon: const Icon(Icons.search),
    dropdownMenuEntries: [
      for (final option in options)
        DropdownMenuEntry<String>(
          value: option.laborId,
          label: _supervisionLaborLabel(option),
          labelWidget: _dropdownItemWithSubtitle(
            option.laborNombre,
            subtitle: option.laborId == option.laborNombre
                ? null
                : 'Código: ${option.laborId}',
          ),
        ),
    ],
    filterCallback: (entries, filter) {
      final q = filter.trim().toLowerCase();
      if (q.isEmpty) return entries;
      return entries.where((entry) {
        final option = byValue[entry.value];
        final haystack = '${option?.laborId ?? ''} ${option?.laborNombre ?? ''}'
            .toLowerCase();
        return haystack.contains(q);
      }).toList();
    },
    onSelected: (nextId) => onChanged(byValue[nextId]),
  );
}

Widget _supervisionResponsiveFields(
  List<CartillaFieldConfig> fields,
  Widget Function(CartillaFieldConfig field) render,
) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final twoColumns = constraints.maxWidth >= 620;
      const gap = 12.0;
      final itemWidth = twoColumns
          ? (constraints.maxWidth - gap) / 2
          : constraints.maxWidth;

      return Wrap(
        spacing: gap,
        runSpacing: 12,
        children: [
          for (final field in fields)
            SizedBox(width: itemWidth, child: render(field)),
        ],
      );
    },
  );
}

Widget _supervisionSummaryStrip(dynamic Function(String) getBodyValue) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 560;
      final itemWidth = compact
          ? constraints.maxWidth
          : (constraints.maxWidth - 16) / 3;

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SizedBox(
            width: itemWidth,
            child: _supervisionMetricTile(
              'Total plantas o racimos',
              _formatNumber(
                getBodyValue(
                  CartillaSupervisionLaborConfig.kTotalPlantasORacimos,
                ),
              ),
            ),
          ),
          SizedBox(
            width: itemWidth,
            child: _supervisionMetricTile(
              'Rendimiento promedio jornal',
              _formatNumber(
                getBodyValue(
                  CartillaSupervisionLaborConfig.kRendimientoPromedioJornal,
                ),
              ),
            ),
          ),
          SizedBox(
            width: itemWidth,
            child: _supervisionMetricTile(
              'N° trabajadores',
              _formatNumber(
                getBodyValue(
                  CartillaSupervisionLaborConfig.kNumeroTrabajadores,
                ),
                decimals: 0,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _supervisionMetricTile(String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: DonLuisColors.primary.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: DonLuisColors.primary.withValues(alpha: 0.16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: DonLuisColors.primary.withValues(alpha: 0.76),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

void _ensureSupervisionDateTimeDefaults({
  required dynamic Function(String) getBodyValue,
  required void Function(String, dynamic) setBodyValue,
  required bool readOnly,
}) {
  if (readOnly) return;

  final nowPe = _nowPeru();
  final defaults = <String, String>{
    CartillaSupervisionLaborConfig.kFecha: _formatDatePe(nowPe),
    CartillaSupervisionLaborConfig.kHoraInicio: _formatTimePe(nowPe),
    CartillaSupervisionLaborConfig.kHoraFinal: _formatTimePe(nowPe),
  };

  final missing = defaults.entries
      .where((entry) => _textValue(getBodyValue(entry.key)).isEmpty)
      .toList();
  if (missing.isEmpty) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    for (final entry in missing) {
      if (_textValue(getBodyValue(entry.key)).isEmpty) {
        setBodyValue(entry.key, entry.value);
      }
    }
  });
}

DateTime _nowPeru() {
  return DateTime.now().toUtc().subtract(const Duration(hours: 5));
}

String _formatDatePe(DateTime value) {
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _formatTimePe(DateTime value) {
  final h = value.hour.toString().padLeft(2, '0');
  final m = value.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

DateTime? _parseDatePe(dynamic value) {
  final text = _textValue(value);
  if (text.isEmpty) return null;
  final parts = text.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

TimeOfDay? _parseTimePe(dynamic value) {
  final text = _textValue(value);
  if (text.isEmpty) return null;
  final parts = text.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
    return null;
  }
  return TimeOfDay(hour: h, minute: m);
}

Widget _supervisionDateField({
  required BuildContext context,
  required String label,
  required dynamic value,
  required bool readOnly,
  required String defaultValue,
  required ValueChanged<String> onChanged,
}) {
  final current = _textValue(value).isEmpty ? defaultValue : _textValue(value);
  return InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: readOnly
        ? null
        : () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _parseDatePe(current) ?? _nowPeru(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) onChanged(_formatDatePe(picked));
          },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
      ),
      child: Text(current),
    ),
  );
}

Widget _supervisionTimeField({
  required BuildContext context,
  required String label,
  required dynamic value,
  required bool readOnly,
  required String defaultValue,
  required ValueChanged<String> onChanged,
}) {
  final current = _textValue(value).isEmpty ? defaultValue : _textValue(value);
  return InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: readOnly
        ? null
        : () async {
            final picked = await showTimePicker(
              context: context,
              initialTime:
                  _parseTimePe(current) ?? TimeOfDay.fromDateTime(_nowPeru()),
            );
            if (picked != null) {
              final h = picked.hour.toString().padLeft(2, '0');
              final m = picked.minute.toString().padLeft(2, '0');
              onChanged('$h:$m');
            }
          },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.schedule_outlined, size: 18),
      ),
      child: Text(current),
    ),
  );
}

String _supervisionSalidaSummary(
  int workerIndex,
  dynamic Function(String) getBodyValue,
) {
  final hora = _textValue(
    getBodyValue(CartillaSupervisionLaborConfig.kHoraSalida(workerIndex)),
  );
  final motivo = _textValue(
    getBodyValue(CartillaSupervisionLaborConfig.kMotivoSalida(workerIndex)),
  );
  final parts = <String>[
    if (hora.isNotEmpty) 'Salida $hora',
    if (motivo.isNotEmpty) motivo,
  ];
  return parts.join(' · ');
}

Widget _supervisionWorkerCard({
  required BuildContext context,
  required int index,
  required bool readOnly,
  required dynamic Function(String) getBodyValue,
  required void Function(String, dynamic) setBodyValue,
  required void Function(Map<String, dynamic>) setBodyValues,
  required VoidCallback onEdit,
}) {
  final name = _textValue(
    getBodyValue(CartillaSupervisionLaborConfig.kNombre(index)),
  );
  final dni = _textValue(
    getBodyValue(CartillaSupervisionLaborConfig.kDni(index)),
  );
  final rows = _supervisionWorkerRows(index, getBodyValue);
  final total = _formatNumber(
    getBodyValue(CartillaSupervisionLaborConfig.kTotal(index)),
  );
  final salidaSummary = _supervisionSalidaSummary(index, getBodyValue);

  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: DonLuisColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: DonLuisColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Trabajador $index' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (dni.isNotEmpty) 'DNI $dni',
                          '${rows.length} ${rows.length == 1 ? 'hilera' : 'hileras'}',
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.56),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      total,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black.withValues(alpha: 0.54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _signatureActionButton(
                    context: context,
                    label: 'Entrada',
                    value: getBodyValue(
                      CartillaSupervisionLaborConfig.kFirmaEntrada(index),
                    ),
                    readOnly: readOnly,
                    compact: true,
                    onChanged: (value) => setBodyValue(
                      CartillaSupervisionLaborConfig.kFirmaEntrada(index),
                      value,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _supervisionSalidaSignatureButton(
                    context: context,
                    label: 'Salida',
                    value: getBodyValue(
                      CartillaSupervisionLaborConfig.kFirmaSalida(index),
                    ),
                    readOnly: readOnly,
                    compact: true,
                    workerIndex: index,
                    getBodyValue: getBodyValue,
                    setBodyValues: setBodyValues,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Editar trabajador',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            if (salidaSummary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                salidaSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget _supervisionWorkerIdentityField({
  required BuildContext context,
  required WidgetRef ref,
  required int workerIndex,
  required bool readOnly,
  required dynamic Function(String) getBodyValue,
  required void Function(String, dynamic) setBodyValue,
}) {
  final nombre = _textValue(
    getBodyValue(CartillaSupervisionLaborConfig.kNombre(workerIndex)),
  );
  final dni = _textValue(
    getBodyValue(CartillaSupervisionLaborConfig.kDni(workerIndex)),
  );

  return _JornalWorkerLookupField(
    key: ValueKey('jornal_lookup_$workerIndex-$dni-$nombre'),
    workerIndex: workerIndex,
    initialNombre: nombre,
    initialDni: dni,
    readOnly: readOnly,
    setBodyValue: setBodyValue,
  );
}

class _JornalWorkerLookupField extends ConsumerStatefulWidget {
  final int workerIndex;
  final String initialNombre;
  final String initialDni;
  final bool readOnly;
  final void Function(String, dynamic) setBodyValue;

  const _JornalWorkerLookupField({
    super.key,
    required this.workerIndex,
    required this.initialNombre,
    required this.initialDni,
    required this.readOnly,
    required this.setBodyValue,
  });

  @override
  ConsumerState<_JornalWorkerLookupField> createState() =>
      _JornalWorkerLookupFieldState();
}

class _JornalWorkerLookupFieldState
    extends ConsumerState<_JornalWorkerLookupField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  List<dynamic> _localPeople = const [];
  var _loading = true;
  late String _selectedDni;

  @override
  void initState() {
    super.initState();
    _selectedDni = widget.initialDni;
    final initial = widget.initialNombre.isNotEmpty
        ? widget.initialNombre
        : widget.initialDni;
    _controller = TextEditingController(text: initial);
    _focusNode = FocusNode();
    _loadLocalPeople();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadLocalPeople() async {
    var people = await ref
        .read(masterLocalDsProvider)
        .getPersonasActivasByTipoCodigo('JOR');
    if (people.isEmpty) {
      final allPeople = await ref
          .read(masterLocalDsProvider)
          .getPersonasActivas();
      people = allPeople.where(_isJornalPersona).toList();
    }
    if (!mounted) return;
    setState(() {
      _localPeople = people;
      _loading = false;
    });
  }

  void _selectPersona(dynamic persona) {
    final map = _personaToMap(persona);
    final id = map['id'];
    final dni = '${map['dni'] ?? ''}'.trim();
    final nombre = '${map['nombreCompleto'] ?? map['nombre_completo'] ?? ''}'
        .trim();

    if (id != null) {
      widget.setBodyValue(
        CartillaSupervisionLaborConfig.kPersonaId(widget.workerIndex),
        id,
      );
    }
    widget.setBodyValue(
      CartillaSupervisionLaborConfig.kDni(widget.workerIndex),
      dni,
    );
    widget.setBodyValue(
      CartillaSupervisionLaborConfig.kNombre(widget.workerIndex),
      nombre,
    );
    _controller.text = nombre;
    setState(() => _selectedDni = dni);
    _focusNode.unfocus();
  }

  List<_JornalWorkerOption> _optionsFor(String rawQuery) {
    final q = rawQuery.trim().toLowerCase();
    if (_loading) return const [];

    final people = q.isEmpty
        ? _localPeople.take(5).toList()
        : _localPeople
              .where((persona) => _matchesJornalQuery(persona, q))
              .take(8)
              .toList();

    if (people.isEmpty && q.isNotEmpty) {
      return [_JornalWorkerOption.add(rawQuery.trim())];
    }

    return people.map(_JornalWorkerOption.persona).toList();
  }

  bool _matchesJornalQuery(dynamic persona, String query) {
    final map = _personaToMap(persona);
    final dni = _normalizeSearchText('${map['dni'] ?? ''}');
    final nombre = _normalizeSearchText(
      '${map['nombreCompleto'] ?? map['nombre_completo'] ?? ''}',
    );
    final haystack = '$nombre $dni';
    final tokens = query
        .split(RegExp(r'\s+'))
        .map(_normalizeSearchText)
        .where((token) => token.isNotEmpty)
        .toList();

    if (tokens.isEmpty) return true;
    return tokens.every(haystack.contains);
  }

  bool _isJornalPersona(dynamic persona) {
    final map = _personaToMap(persona);
    final codigo = _normalizeSearchText(
      '${map['tipoCodigo'] ?? map['tipo_codigo'] ?? ''}',
    );
    final descripcion = _normalizeSearchText(
      '${map['tipoDescripcion'] ?? map['tipo_descripcion'] ?? ''}',
    );
    return codigo == 'jor' ||
        codigo == 'jornal' ||
        descripcion.contains('jornal');
  }

  String _normalizeSearchText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll('ñ', 'n');
  }

  Future<void> _addJornalWorker(String query) async {
    final digits = query.replaceAll(RegExp(r'\D'), '');
    final selected = await _showAddJornalWorkerDialog(
      context: context,
      ref: ref,
      workerIndex: widget.workerIndex,
      setBodyValue: widget.setBodyValue,
      initialDni: digits.length <= 8 ? digits : '',
    );
    await _loadLocalPeople();
    if (selected != null) {
      _selectPersona(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<_JornalWorkerOption>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: (option) => option.displayLabel,
      optionsBuilder: (textEditingValue) => _optionsFor(textEditingValue.text),
      onSelected: (option) {
        if (option.isAdd) {
          _addJornalWorker(option.query);
          return;
        }
        _selectPersona(option.persona);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: widget.readOnly,
              decoration: InputDecoration(
                labelText: 'Trabajador jornal',
                hintText: 'Busca por nombre o DNI',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _selectedDni.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar trabajador',
                        icon: const Icon(Icons.close),
                        onPressed: widget.readOnly
                            ? null
                            : () {
                                widget.setBodyValue(
                                  CartillaSupervisionLaborConfig.kPersonaId(
                                    widget.workerIndex,
                                  ),
                                  null,
                                );
                                widget.setBodyValue(
                                  CartillaSupervisionLaborConfig.kDni(
                                    widget.workerIndex,
                                  ),
                                  null,
                                );
                                widget.setBodyValue(
                                  CartillaSupervisionLaborConfig.kNombre(
                                    widget.workerIndex,
                                  ),
                                  null,
                                );
                                controller.clear();
                                setState(() => _selectedDni = '');
                                focusNode.requestFocus();
                              },
                      ),
              ),
            ),
            if (_selectedDni.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  'DNI $_selectedDni',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.58),
                  ),
                ),
              ),
            ],
          ],
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (widget.readOnly) return const SizedBox.shrink();

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, maxWidth: 560),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  if (option.isAdd) {
                    final dniQuery = option.query.replaceAll(RegExp(r'\D'), '');
                    return ListTile(
                      leading: const Icon(Icons.person_add_alt_1_outlined),
                      title: const Text(
                        'Agregar trabajador',
                        style: TextStyle(color: Colors.black87),
                      ),
                      subtitle: Text(
                        dniQuery.isEmpty
                            ? 'Ingresa su DNI para consultar el servicio externo'
                            : 'Consultar DNI $dniQuery',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.62),
                        ),
                      ),
                      onTap: () => onSelected(option),
                    );
                  }

                  final map = _personaToMap(option.persona);
                  final dni = '${map['dni'] ?? ''}'.trim();
                  final nombre =
                      '${map['nombreCompleto'] ?? map['nombre_completo'] ?? ''}'
                          .trim();
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.badge_outlined),
                    title: Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    subtitle: Text(
                      'DNI $dni',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.62),
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _JornalWorkerOption {
  final dynamic persona;
  final String query;
  final bool isAdd;

  const _JornalWorkerOption.persona(this.persona) : query = '', isAdd = false;

  const _JornalWorkerOption.add(this.query) : persona = null, isAdd = true;

  String get displayLabel {
    if (isAdd) return query;
    final map = _personaToMap(persona);
    return '${map['nombreCompleto'] ?? map['nombre_completo'] ?? ''}'.trim();
  }
}

Future<dynamic> _showAddJornalWorkerDialog({
  required BuildContext context,
  required WidgetRef ref,
  required int workerIndex,
  required void Function(String, dynamic) setBodyValue,
  String initialDni = '',
}) async {
  final dniCtrl = TextEditingController();
  dniCtrl.text = initialDni;
  final nombreCtrl = TextEditingController();
  var loading = false;
  String? message;
  var closed = false;
  dynamic selectedPersona;

  Future<void> selectPersona(dynamic persona) async {
    final map = _personaToMap(persona);
    final id = map['id'];
    final dni = '${map['dni'] ?? ''}'.trim();
    final nombre = '${map['nombreCompleto'] ?? map['nombre_completo'] ?? ''}'
        .trim();

    if (id != null) {
      setBodyValue(CartillaSupervisionLaborConfig.kPersonaId(workerIndex), id);
    }
    setBodyValue(CartillaSupervisionLaborConfig.kDni(workerIndex), dni);
    setBodyValue(CartillaSupervisionLaborConfig.kNombre(workerIndex), nombre);
    selectedPersona = persona;
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> consultarYGuardar() async {
            final dni = dniCtrl.text.trim();
            if (dni.length != 8 || int.tryParse(dni) == null) {
              setDialogState(() {
                message = 'Ingresa un DNI válido de 8 dígitos.';
              });
              return;
            }

            setDialogState(() {
              loading = true;
              message = null;
            });

            try {
              final local = ref.read(masterLocalDsProvider);
              final localMatches = await local.getPersonasActivasByTipoCodigo(
                'JOR',
              );
              for (final persona in localMatches) {
                final map = _personaToMap(persona);
                if ('${map['dni'] ?? ''}'.trim() == dni) {
                  await selectPersona(persona);
                  closed = true;
                  if (context.mounted) Navigator.of(context).pop();
                  return;
                }
              }

              final repo = ref.read(personasRepoProvider);
              final lookup = await repo.consultarDni(dni);
              final nombre = (lookup.nombreCompleto ?? '').trim();
              if (!lookup.found || nombre.isEmpty) {
                setDialogState(() {
                  message =
                      lookup.message ??
                      'No se encontró información para el DNI indicado.';
                });
                return;
              }

              nombreCtrl.text = nombre;
              final persona = await _registerJornalPersona(
                ref: ref,
                dni: dni,
                nombreCompleto: nombre,
              );
              await _saveJornalPersonaLocal(ref, persona);
              await selectPersona(persona);
              closed = true;
              if (context.mounted) Navigator.of(context).pop();
            } catch (e) {
              setDialogState(() {
                message = _jornalRegisterErrorMessage(e);
              });
            } finally {
              if (!closed) {
                setDialogState(() => loading = false);
              }
            }
          }

          return AlertDialog(
            title: const Text('Agregar trabajador'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dniCtrl,
                    enabled: !loading,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'DNI',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    onSubmitted: (_) => consultarYGuardar(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nombreCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Nombre consultado',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      message!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: loading ? null : consultarYGuardar,
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: const Text('Consultar y agregar'),
              ),
            ],
          );
        },
      );
    },
  );

  return selectedPersona;
}

String _jornalRegisterErrorMessage(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 403) {
      return 'La API no permite registrar jornaleros con este usuario. Actualiza el backend con el endpoint de jornales o revisa permisos.';
    }
    if (statusCode == 404) {
      return 'La API no tiene habilitado el registro de jornaleros. Reinicia o despliega el backend actualizado.';
    }
    if (statusCode != null) {
      return 'No se pudo registrar el trabajador. Código HTTP $statusCode.';
    }
  }

  return 'No se pudo registrar el trabajador: $error';
}

Future<dynamic> _registerJornalPersona({
  required WidgetRef ref,
  required String dni,
  required String nombreCompleto,
}) async {
  final repo = ref.read(personasRepoProvider);

  try {
    return await repo.upsertJornalPersona(
      dni: dni,
      nombreCompleto: nombreCompleto,
    );
  } on DioException catch (e) {
    if (e.response?.statusCode != 404) rethrow;
  }

  final local = ref.read(masterLocalDsProvider);
  final tipos = await local.getPersonaTiposActivos();
  dynamic jornalTipo;
  for (final tipo in tipos) {
    final map = _personaTipoToMap(tipo);
    final codigo = '${map['codigo'] ?? ''}'.trim().toUpperCase();
    if (codigo == 'JOR') {
      jornalTipo = tipo;
      break;
    }
  }

  if (jornalTipo == null) {
    throw StateError(
      'No se encontró el tipo de persona JOR en la tablet. Sincroniza maestros e intenta nuevamente.',
    );
  }

  final tipoMap = _personaTipoToMap(jornalTipo);
  final tipoId = (tipoMap['id'] as num).toInt();

  try {
    return await repo.createPersona(
      dni: dni,
      nombreCompleto: nombreCompleto,
      tipoId: tipoId,
      estado: true,
    );
  } on DioException catch (e) {
    if (e.response?.statusCode == 400) {
      final existing = await repo.fetchPersonas(dni: dni, estado: true);
      if (existing.isNotEmpty) return existing.first;
    }
    rethrow;
  }
}

Map<String, dynamic> _personaTipoToMap(dynamic tipo) {
  try {
    final map = (tipo as dynamic).toJson();
    if (map is Map) return map.cast<String, dynamic>();
  } catch (_) {}

  return {
    'id': (tipo as dynamic).id,
    'codigo': (tipo as dynamic).codigo,
    'descripcion': (tipo as dynamic).descripcion,
    'estado': (tipo as dynamic).estado,
  };
}

Map<String, dynamic> _personaToMap(dynamic persona) {
  try {
    final map = (persona as dynamic).toJson();
    if (map is Map) return map.cast<String, dynamic>();
  } catch (_) {}

  return {
    'id': (persona as dynamic).id,
    'dni': (persona as dynamic).dni,
    'nombreCompleto': (persona as dynamic).nombreCompleto,
    'tipoId': (persona as dynamic).tipoId,
    'tipoCodigo': (persona as dynamic).tipoCodigo,
    'tipoDescripcion': (persona as dynamic).tipoDescripcion,
    'estado': (persona as dynamic).estado,
  };
}

Future<void> _saveJornalPersonaLocal(WidgetRef ref, dynamic persona) async {
  await ref.read(masterLocalDsProvider).savePersonas([
    PersonasTableCompanion.insert(
      id: drift.Value((persona as dynamic).id as int),
      dni: (persona as dynamic).dni as String,
      nombreCompleto: (persona as dynamic).nombreCompleto as String,
      tipoId: (persona as dynamic).tipoId as int,
      tipoCodigo: (persona as dynamic).tipoCodigo as String,
      tipoDescripcion: (persona as dynamic).tipoDescripcion as String,
      estado: drift.Value((persona as dynamic).estado as bool),
    ),
  ]);
}

Future<void> _showSupervisionWorkerSheet({
  required BuildContext context,
  required WidgetRef ref,
  required bool readOnly,
  required dynamic Function(String) getBodyValue,
  required void Function(String, dynamic) setBodyValue,
  required int workerIndex,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      final i = workerIndex;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Trabajador $i',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _supervisionWorkerIdentityField(
                context: context,
                ref: ref,
                workerIndex: i,
                readOnly: readOnly,
                getBodyValue: getBodyValue,
                setBodyValue: setBodyValue,
              ),
              const SizedBox(height: 12),
              _supervisionRowsEditor(
                workerIndex: i,
                readOnly: readOnly,
                getBodyValue: getBodyValue,
                setBodyValue: setBodyValue,
              ),
              const SizedBox(height: 14),
              _signatureActionButton(
                context: context,
                label: 'Firma entrada',
                value: getBodyValue(
                  CartillaSupervisionLaborConfig.kFirmaEntrada(i),
                ),
                readOnly: readOnly,
                onChanged: (value) => setBodyValue(
                  CartillaSupervisionLaborConfig.kFirmaEntrada(i),
                  value,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Listo'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _supervisionRowsEditor({
  required int workerIndex,
  required bool readOnly,
  required dynamic Function(String) getBodyValue,
  required void Function(String, dynamic) setBodyValue,
}) {
  return _SupervisionRowsEditor(
    initialRows: _supervisionWorkerRows(workerIndex, getBodyValue),
    rowsKey: _supervisionRowsKey(workerIndex),
    readOnly: readOnly,
    setBodyValue: setBodyValue,
  );
}

class _SupervisionRowsEditor extends StatefulWidget {
  final List<Map<String, dynamic>> initialRows;
  final String rowsKey;
  final bool readOnly;
  final void Function(String, dynamic) setBodyValue;

  const _SupervisionRowsEditor({
    required this.initialRows,
    required this.rowsKey,
    required this.readOnly,
    required this.setBodyValue,
  });

  @override
  State<_SupervisionRowsEditor> createState() => _SupervisionRowsEditorState();
}

class _SupervisionRowsEditorState extends State<_SupervisionRowsEditor> {
  late List<Map<String, dynamic>> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.initialRows.isEmpty
        ? [_emptySupervisionRow()]
        : widget.initialRows
              .map((row) => Map<String, dynamic>.from(row))
              .toList();
  }

  void _commit() {
    final rowsToSave = _rows
        .where((row) {
          return row.entries.any((entry) {
            if (entry.key == 'subtotal' || entry.key == 'total') return false;
            return _textValue(entry.value).isNotEmpty;
          });
        })
        .map((row) {
          return {
            ...row,
            'subtotal': _supervisionRowSubtotal(row),
            'total': _supervisionRowTotal(row),
          };
        })
        .toList();

    widget.setBodyValue(widget.rowsKey, rowsToSave);
  }

  void _updateRow(int index, String key, dynamic value) {
    setState(() {
      _rows[index] = {..._rows[index], key: value};
    });
    _commit();
  }

  void _addRow() {
    setState(() => _rows.add(_emptySupervisionRow()));
    _commit();
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index);
      if (_rows.isEmpty) _rows.add(_emptySupervisionRow());
    });
    _commit();
  }

  @override
  Widget build(BuildContext context) {
    final total = _rows.fold<double>(
      0,
      (sum, row) => sum + _supervisionRowTotal(row),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Hileras',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            OutlinedButton.icon(
              onPressed: widget.readOnly ? null : _addRow,
              icon: const Icon(Icons.add),
              label: const Text('Agregar hilera'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < _rows.length; i++) ...[
          _supervisionRowEditor(
            rowNumber: i + 1,
            row: _rows[i],
            readOnly: widget.readOnly,
            canRemove:
                _rows.length > 1 ||
                _rows[i].entries.any(
                  (entry) => _textValue(entry.value).isNotEmpty,
                ),
            onChanged: (key, value) => _updateRow(i, key, value),
            onRemove: () => _removeRow(i),
          ),
          const SizedBox(height: 10),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: DonLuisColors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Total trabajador',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                _formatNumber(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _supervisionRowEditor({
  required int rowNumber,
  required Map<String, dynamic> row,
  required bool readOnly,
  required bool canRemove,
  required void Function(String key, dynamic value) onChanged,
  required VoidCallback onRemove,
}) {
  final subtotal = _supervisionRowSubtotal(row);
  final total = _supervisionRowTotal(row);

  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Hilera $rowNumber',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(
              tooltip: 'Quitar hilera',
              onPressed: readOnly || !canRemove ? null : onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 360;
            final width = twoColumns
                ? (constraints.maxWidth - 10) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: width,
                  child: _supervisionSmallIntField(
                    label: 'Hilera',
                    value: row['hilera'],
                    readOnly: readOnly,
                    onChanged: (value) => onChanged('hilera', value),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _supervisionSmallIntField(
                    label: 'Inicio',
                    value: row['plantasInicio'],
                    readOnly: readOnly,
                    onChanged: (value) => onChanged('plantasInicio', value),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _supervisionSmallIntField(
                    label: 'Final',
                    value: row['plantasFinal'],
                    readOnly: readOnly,
                    onChanged: (value) => onChanged('plantasFinal', value),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _supervisionSmallIntField(
                    label: 'Rechazadas',
                    value: row['plantasRacimoRechazado'],
                    readOnly: readOnly,
                    onChanged: (value) =>
                        onChanged('plantasRacimoRechazado', value),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _supervisionInlineMetric('Subtotal', subtotal)),
            const SizedBox(width: 10),
            Expanded(child: _supervisionInlineMetric('Total', total)),
          ],
        ),
      ],
    ),
  );
}

Widget _supervisionInlineMetric(String label, double value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.035),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withValues(alpha: 0.60),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          _formatNumber(value),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

Widget _supervisionSmallIntField({
  required String label,
  required dynamic value,
  required bool readOnly,
  required ValueChanged<int?> onChanged,
}) {
  final text = _textValue(value);
  return TextFormField(
    initialValue: text,
    readOnly: readOnly,
    enabled: !readOnly,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      hintText: '0',
    ),
    onChanged: (text) => onChanged(text.isEmpty ? null : int.tryParse(text)),
  );
}

Widget _supervisionSalidaSignatureButton({
  required BuildContext context,
  required String label,
  required dynamic value,
  required bool readOnly,
  required int workerIndex,
  required dynamic Function(String) getBodyValue,
  required void Function(Map<String, dynamic>) setBodyValues,
  bool compact = false,
}) {
  final signed = _hasSignature(value);
  return OutlinedButton.icon(
    onPressed: readOnly
        ? null
        : () => _showSupervisionSalidaSignatureDialog(
            context: context,
            label: label,
            value: value,
            readOnly: readOnly,
            workerIndex: workerIndex,
            getBodyValue: getBodyValue,
            setBodyValues: setBodyValues,
          ),
    icon: Icon(
      signed ? Icons.check_circle : Icons.draw_outlined,
      size: compact ? 18 : 20,
    ),
    label: Text(
      signed ? '$label firmada' : label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Future<void> _showSupervisionSalidaSignatureDialog({
  required BuildContext context,
  required String label,
  required dynamic value,
  required bool readOnly,
  required int workerIndex,
  required dynamic Function(String) getBodyValue,
  required void Function(Map<String, dynamic>) setBodyValues,
}) {
  var draft = value;
  var hora = _textValue(
    getBodyValue(CartillaSupervisionLaborConfig.kHoraSalida(workerIndex)),
  );
  var motivo = _textValue(
    getBodyValue(CartillaSupervisionLaborConfig.kMotivoSalida(workerIndex)),
  );
  var observacion = _textValue(
    getBodyValue(
      CartillaSupervisionLaborConfig.kObservacionSalida(workerIndex),
    ),
  );

  return showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedMotivo =
              CartillaSupervisionLaborConfig.motivoSalidaOptions.contains(
                motivo,
              )
              ? motivo
              : null;

          return AlertDialog(
            title: Text(label),
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SignaturePadField(
                      label: 'Firma',
                      value: draft,
                      readOnly: readOnly,
                      onChanged: (signature) {
                        setDialogState(() {
                          draft = signature;
                          if (signature.isNotEmpty && hora.isEmpty) {
                            hora = _formatTimePe(_nowPeru());
                          } else if (signature.isEmpty) {
                            hora = '';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hora de salida',
                        suffixIcon: Icon(Icons.schedule_outlined, size: 18),
                      ),
                      child: Text(
                        hora.isEmpty ? 'Se registra al firmar salida' : hora,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      key: ValueKey(
                        'dialog_motivo_salida_$workerIndex-$motivo',
                      ),
                      isExpanded: true,
                      value: selectedMotivo,
                      decoration: const InputDecoration(
                        labelText: 'Motivo de salida',
                      ),
                      items: [
                        for (final option
                            in CartillaSupervisionLaborConfig
                                .motivoSalidaOptions)
                          DropdownMenuItem<String>(
                            value: option,
                            child: _dropdownItemText(option),
                          ),
                      ],
                      onChanged: readOnly
                          ? null
                          : (value) {
                              setDialogState(() => motivo = value ?? '');
                            },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: ValueKey(
                        'dialog_observacion_salida_$workerIndex-$observacion',
                      ),
                      initialValue: observacion,
                      enabled: !readOnly,
                      readOnly: readOnly,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones de salida',
                      ),
                      onChanged: (value) {
                        observacion = value;
                      },
                    ),
                    if (!_hasSignature(draft) || selectedMotivo == null) ...[
                      const SizedBox(height: 10),
                      Text(
                        !_hasSignature(draft)
                            ? 'Dibuja la firma para guardar la salida.'
                            : 'Selecciona el motivo de salida.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed:
                    readOnly || !_hasSignature(draft) || selectedMotivo == null
                    ? null
                    : () {
                        final salidaHora = hora.isNotEmpty
                            ? hora
                            : _formatTimePe(_nowPeru());
                        setBodyValues({
                          CartillaSupervisionLaborConfig.kFirmaSalida(
                            workerIndex,
                          ): draft,
                          CartillaSupervisionLaborConfig.kHoraSalida(
                            workerIndex,
                          ): salidaHora,
                          CartillaSupervisionLaborConfig.kMotivoSalida(
                            workerIndex,
                          ): motivo,
                          CartillaSupervisionLaborConfig.kObservacionSalida(
                            workerIndex,
                          ): observacion,
                        });
                        Navigator.of(context).pop();
                      },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar salida'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _signatureActionButton({
  required BuildContext context,
  required String label,
  required dynamic value,
  required bool readOnly,
  required ValueChanged<List<List<Map<String, double>>>> onChanged,
  bool compact = false,
}) {
  final signed = _hasSignature(value);
  return OutlinedButton.icon(
    onPressed: readOnly
        ? null
        : () => _showSignatureDialog(
            context: context,
            label: label,
            value: value,
            readOnly: readOnly,
            onChanged: onChanged,
          ),
    icon: Icon(
      signed ? Icons.check_circle : Icons.draw_outlined,
      size: compact ? 18 : 20,
    ),
    label: Text(
      signed ? '$label firmada' : label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Future<void> _showSignatureDialog({
  required BuildContext context,
  required String label,
  required dynamic value,
  required bool readOnly,
  required ValueChanged<List<List<Map<String, double>>>> onChanged,
}) {
  var draft = value;
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(label),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        content: SizedBox(
          width: 620,
          child: _SignaturePadField(
            label: 'Firma',
            value: draft,
            readOnly: readOnly,
            onChanged: (value) {
              draft = value;
              onChanged(value);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

int _supervisionVisibleWorkers(dynamic Function(String) getBodyValue) {
  final configured = getBodyValue('trabajadoresVisibles');
  final configuredInt = configured is num
      ? configured.toInt()
      : int.tryParse('$configured');
  var maxUsed = 1;

  for (var i = 1; i <= 6; i++) {
    if (_supervisionWorkerHasData(i, getBodyValue)) maxUsed = i;
  }

  final visible = configuredInt == null || configuredInt < maxUsed
      ? maxUsed
      : configuredInt;
  return visible.clamp(1, 6);
}

bool _supervisionWorkerHasData(int i, dynamic Function(String) getBodyValue) {
  final rows = _supervisionWorkerRows(i, getBodyValue);
  final keys = [
    CartillaSupervisionLaborConfig.kNombre(i),
    CartillaSupervisionLaborConfig.kDni(i),
    CartillaSupervisionLaborConfig.kHoraSalida(i),
    CartillaSupervisionLaborConfig.kMotivoSalida(i),
    CartillaSupervisionLaborConfig.kObservacionSalida(i),
  ];

  for (final key in keys) {
    if (_textValue(getBodyValue(key)).isNotEmpty) return true;
  }
  return rows.isNotEmpty ||
      _hasSignature(
        getBodyValue(CartillaSupervisionLaborConfig.kFirmaEntrada(i)),
      ) ||
      _hasSignature(
        getBodyValue(CartillaSupervisionLaborConfig.kFirmaSalida(i)),
      );
}

String _supervisionRowsKey(int workerIndex) {
  return 'trabajador${workerIndex}_hileras';
}

List<Map<String, dynamic>> _supervisionWorkerRows(
  int workerIndex,
  dynamic Function(String) getBodyValue,
) {
  final rawRows = getBodyValue(_supervisionRowsKey(workerIndex));
  if (rawRows is List && rawRows.isNotEmpty) {
    return rawRows
        .whereType<dynamic>()
        .map(
          (row) =>
              row is Map ? Map<String, dynamic>.from(row) : <String, dynamic>{},
        )
        .where((row) => row.isNotEmpty)
        .toList();
  }

  final legacyRow = _emptySupervisionRow()
    ..['hilera'] = getBodyValue(
      CartillaSupervisionLaborConfig.kHilera(workerIndex),
    )
    ..['plantasInicio'] = getBodyValue(
      CartillaSupervisionLaborConfig.kPlantasInicio(workerIndex),
    )
    ..['plantasFinal'] = getBodyValue(
      CartillaSupervisionLaborConfig.kPlantasFinal(workerIndex),
    )
    ..['plantasRacimoRechazado'] = getBodyValue(
      CartillaSupervisionLaborConfig.kPlantasRechazadas(workerIndex),
    );

  final hasLegacy = legacyRow.values.any(
    (value) => _textValue(value).isNotEmpty,
  );
  return hasLegacy ? [legacyRow] : <Map<String, dynamic>>[];
}

Map<String, dynamic> _emptySupervisionRow() {
  return {
    'hilera': null,
    'plantasInicio': null,
    'plantasFinal': null,
    'subtotal': 0.0,
    'plantasRacimoRechazado': 0,
    'total': 0.0,
  };
}

int _rowInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _supervisionRowSubtotal(Map<String, dynamic> row) {
  final inicio = _rowInt(row['plantasInicio']);
  final fin = _rowInt(row['plantasFinal']);
  if (inicio < 0 || fin < inicio) return 0.0;
  return (fin - inicio).toDouble();
}

double _supervisionRowTotal(Map<String, dynamic> row) {
  final total =
      _supervisionRowSubtotal(row) - _rowInt(row['plantasRacimoRechazado']);
  return total < 0 ? 0.0 : total;
}

bool _hasSignature(dynamic value) {
  return value is Iterable && value.isNotEmpty;
}

String _textValue(dynamic value) {
  if (value == null) return '';
  if (value is num && value == 0) return '';
  final text = value.toString().trim();
  return text == '0' || text == '0.0' ? '' : text;
}

String _formatNumber(dynamic value, {int decimals = 2}) {
  if (value == null) return decimals == 0 ? '0' : '0.00';
  final n = value is num ? value.toDouble() : double.tryParse('$value');
  if (n == null) return '$value';
  return decimals == 0 ? n.round().toString() : n.toStringAsFixed(decimals);
}

class _GaritaDniLookupField extends ConsumerStatefulWidget {
  const _GaritaDniLookupField({
    required this.ref,
    required this.readOnly,
    required this.dni,
    required this.apellidosNombres,
    required this.onDniChanged,
    required this.onApellidosNombresChanged,
  });

  final WidgetRef ref;
  final bool readOnly;
  final String dni;
  final String apellidosNombres;
  final ValueChanged<String> onDniChanged;
  final ValueChanged<String> onApellidosNombresChanged;

  @override
  ConsumerState<_GaritaDniLookupField> createState() =>
      _GaritaDniLookupFieldState();
}

class _GaritaDniLookupFieldState extends ConsumerState<_GaritaDniLookupField> {
  late final TextEditingController _dniCtrl;
  late final TextEditingController _nombreCtrl;
  bool _consulting = false;

  @override
  void initState() {
    super.initState();
    _dniCtrl = TextEditingController(text: widget.dni);
    _nombreCtrl = TextEditingController(text: widget.apellidosNombres);
  }

  @override
  void didUpdateWidget(covariant _GaritaDniLookupField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dni != oldWidget.dni && widget.dni != _dniCtrl.text) {
      _dniCtrl.text = widget.dni;
    }
    if (widget.apellidosNombres != oldWidget.apellidosNombres &&
        widget.apellidosNombres != _nombreCtrl.text) {
      _nombreCtrl.text = widget.apellidosNombres;
    }
  }

  @override
  void dispose() {
    _dniCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _consultarDni() async {
    final dni = _dniCtrl.text.trim();
    if (dni.length != 8 || int.tryParse(dni) == null) {
      _showMessage('El DNI debe tener exactamente 8 dígitos.', isError: true);
      return;
    }

    setState(() => _consulting = true);
    try {
      final result = await widget.ref
          .read(personasRepoProvider)
          .consultarDni(dni);
      if (!mounted) return;

      final nombre = (result.nombreCompleto ?? '').trim();
      if (result.found && nombre.isNotEmpty) {
        _nombreCtrl.text = nombre;
        widget.onApellidosNombresChanged(nombre);
        _showMessage('DNI consultado correctamente.');
      } else {
        _showMessage(
          result.message ??
              'No se encontró información. Ingresa el nombre manualmente.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        'No se pudo consultar el DNI. Ingresa el nombre manualmente.',
      );
    } finally {
      if (mounted) setState(() => _consulting = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _dniCtrl,
          readOnly: widget.readOnly || _consulting,
          enabled: !widget.readOnly,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          decoration: InputDecoration(
            labelText: '1. DNI',
            suffixIcon: IconButton(
              tooltip: 'Consultar DNI',
              onPressed: widget.readOnly || _consulting ? null : _consultarDni,
              icon: _consulting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
            ),
          ),
          onChanged: widget.onDniChanged,
          onFieldSubmitted: (_) {
            if (!widget.readOnly && !_consulting) _consultarDni();
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nombreCtrl,
          readOnly: widget.readOnly,
          enabled: !widget.readOnly,
          maxLines: 1,
          decoration: const InputDecoration(labelText: 'Apellidos y nombres'),
          onChanged: widget.onApellidosNombresChanged,
        ),
      ],
    );
  }
}

Widget _renderField({
  required BuildContext context,
  required WidgetRef ref,
  required CartillaFieldConfig field,
  required CartillaFormConfig config,
  required int localId,
  required PhotoService photoService,
  required bool readOnly,
  required dynamic currentPayload,
  required void Function(dynamic nextPayload) commitPayload,
  required dynamic Function(String) getHeaderValue,
  required void Function(String, dynamic) setHeaderValue,
  required dynamic Function(String) getBodyValue,
  required int Function(String) getBodyInt,
  required void Function(String, dynamic) setBodyValue,
  required void Function(Map<String, dynamic>) setBodyValues,
  dynamic Function(String)? getReferenceBodyValue,
  dynamic Function(String)? getReferenceHeaderValue,
  bool comparativeMode = false,
  String? photoListBodyKeyOverride,
}) {
  final fieldReadOnly = readOnly || field.rules.readOnly;
  final isHeader = config.headerKeys.contains(field.key);
  final isGaritaTemplate =
      config.templateKey ==
      CartillaRegistroPersonalGaritaSeguridadConfig.templateKeyStatic;

  if (isGaritaTemplate &&
      field.key == CartillaRegistroPersonalGaritaSeguridadConfig.kDni) {
    return _GaritaDniLookupField(
      ref: ref,
      readOnly: fieldReadOnly,
      dni: _textValue(
        getBodyValue(CartillaRegistroPersonalGaritaSeguridadConfig.kDni),
      ),
      apellidosNombres: _textValue(
        getBodyValue(
          CartillaRegistroPersonalGaritaSeguridadConfig.kApellidosNombres,
        ),
      ),
      onDniChanged: (value) => setBodyValue(
        CartillaRegistroPersonalGaritaSeguridadConfig.kDni,
        value,
      ),
      onApellidosNombresChanged: (value) => setBodyValue(
        CartillaRegistroPersonalGaritaSeguridadConfig.kApellidosNombres,
        value,
      ),
    );
  }

  if (isGaritaTemplate &&
      field.key ==
          CartillaRegistroPersonalGaritaSeguridadConfig.kApellidosNombres) {
    return const SizedBox.shrink();
  }

  Widget withReference(Widget child, {dynamic currentValue}) {
    return _wrapFieldWithReference(
      field: field,
      comparativeMode: comparativeMode,
      fieldReadOnly: fieldReadOnly,
      currentValue: currentValue,
      getReferenceBodyValue: getReferenceBodyValue,
      getReferenceHeaderValue: isHeader ? getReferenceHeaderValue : null,
      child: child,
    );
  }

  bool isLoteDropdownField(CartillaFieldConfig f) {
    if (f.catalogSource == CartillaCatalogSource.lotes) return true;
    const loteKeys = {'loteId', 'id_lote', 'idLote'};
    return loteKeys.contains(f.key);
  }

  switch (field.type) {
    case CartillaFieldType.dropdown:
      {
        final value = isHeader
            ? getHeaderValue(field.key)
            : getBodyValue(field.key);

        // ✅ Dropdown dinámico por catálogo
        if (field.catalogSource != null) {
          switch (field.catalogSource!) {
            case CartillaCatalogSource.campanias:
              {
                final campAsync = ref.watch(catalogCampaniasProvider);

                return campAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando campañas',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final items = _itemsFromDrift(list);
                    final v = value?.toString();
                    final exists = items.any((it) => it.value == v);

                    return withReference(
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: (v != null && exists) ? v : null,
                        decoration: InputDecoration(
                          labelText: field.label,
                          helperText: items.isEmpty
                              ? 'Sin campañas sincronizadas'
                              : null,
                        ),
                        items: items,
                        onChanged: fieldReadOnly
                            ? null
                            : (v2) {
                                isHeader
                                    ? setHeaderValue(field.key, v2)
                                    : setBodyValue(field.key, v2);

                                // ✅ limpia dependientes (ej: loteId cuando cambia campaña)
                                for (final s in config.sections) {
                                  for (final f in s.fields) {
                                    if (f.dependsOnHeaderKey == field.key) {
                                      setHeaderValue(f.key, null);
                                    }
                                  }
                                }
                              },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.variedades:
              {
                final varAsync = ref.watch(catalogVariedadesProvider);

                return varAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando variedades',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final items = _itemsFromDrift(list);
                    final v = value?.toString();
                    final exists = items.any((it) => it.value == v);

                    return withReference(
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: (v != null && exists) ? v : null,
                        decoration: InputDecoration(
                          labelText: field.label,
                          helperText: items.isEmpty
                              ? 'Sin variedades sincronizadas'
                              : null,
                        ),
                        items: items,
                        onChanged: fieldReadOnly
                            ? null
                            : (v2) {
                                isHeader
                                    ? setHeaderValue(field.key, v2)
                                    : setBodyValue(field.key, v2);
                              },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.cultivos:
              {
                final lotesAsync = ref.watch(catalogLotesProvider);

                return lotesAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando cultivos',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final seen = <String>{};
                    final options = <String>[];
                    for (final lote in list) {
                      final map = _driftToMap(lote);
                      final cultivo =
                          '${map['cultivo'] ?? map['CULTIVO'] ?? ''}'.trim();
                      if (cultivo.isEmpty) continue;
                      final key = cultivo.toUpperCase();
                      if (seen.add(key)) options.add(cultivo);
                    }
                    options.sort();

                    final v = value?.toString();
                    final selected = (v != null && options.contains(v))
                        ? v
                        : null;

                    return withReference(
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selected,
                        decoration: InputDecoration(
                          labelText: field.label,
                          helperText: options.isEmpty
                              ? 'Sin cultivos sincronizados'
                              : null,
                        ),
                        items: options
                            .map(
                              (o) => DropdownMenuItem(
                                value: o,
                                child: _dropdownItemText(o),
                              ),
                            )
                            .toList(),
                        onChanged: fieldReadOnly
                            ? null
                            : (v2) {
                                isHeader
                                    ? setHeaderValue(field.key, v2)
                                    : setBodyValue(field.key, v2);
                              },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.personas:
              {
                final personasAsync = ref.watch(catalogPersonasActivasProvider);

                return personasAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando personas',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final options = _personOptionsFromDrift(list);
                    final v = value?.toString();
                    final exists = options.any((it) => it.value == v);

                    return withReference(
                      _searchableCatalogField(
                        label: field.label,
                        options: options,
                        value: (v != null && exists) ? v : null,
                        helperText: options.isEmpty
                            ? 'Sin personas activas sincronizadas'
                            : null,
                        enabled: !fieldReadOnly,
                        onChanged: (v2) {
                          isHeader
                              ? setHeaderValue(field.key, v2)
                              : setBodyValue(field.key, v2);
                        },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.personasPodador:
              {
                final personasAsync = ref.watch(
                  catalogPersonasPodActivasProvider,
                );

                return personasAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando podadores',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final options = _personOptionsFromDrift(list);
                    final v = value?.toString();
                    final exists = options.any((it) => it.value == v);

                    return withReference(
                      _searchableCatalogField(
                        label: field.label,
                        options: options,
                        value: (v != null && exists) ? v : null,
                        helperText: options.isEmpty
                            ? 'Sin operarios activos sincronizados'
                            : null,
                        enabled: !fieldReadOnly,
                        onChanged: (v2) {
                          isHeader
                              ? setHeaderValue(field.key, v2)
                              : setBodyValue(field.key, v2);
                        },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.personasOperario:
              {
                final personasAsync = ref.watch(
                  personasActivasByTipoCodigoProvider('OPE'),
                );

                return personasAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando operarios',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final options = _personOptionsFromDrift(list);
                    final v = value?.toString();
                    final exists = options.any((it) => it.value == v);

                    return withReference(
                      _searchableCatalogField(
                        label: field.label,
                        options: options,
                        value: (v != null && exists) ? v : null,
                        helperText: options.isEmpty
                            ? 'Sin operarios activos sincronizados'
                            : null,
                        enabled: !fieldReadOnly,
                        onChanged: (v2) {
                          isHeader
                              ? setHeaderValue(field.key, v2)
                              : setBodyValue(field.key, v2);
                        },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.personasSupervisor:
              {
                final personasAsync = ref.watch(
                  catalogPersonasSupActivasProvider,
                );

                return personasAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando supervisores',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final options = _personOptionsFromDrift(list);
                    final v = value?.toString();
                    final exists = options.any((it) => it.value == v);

                    return withReference(
                      _searchableCatalogField(
                        label: field.label,
                        options: options,
                        value: (v != null && exists) ? v : null,
                        helperText: options.isEmpty
                            ? 'Sin supervisores activos sincronizados'
                            : null,
                        enabled: !fieldReadOnly,
                        onChanged: (v2) {
                          isHeader
                              ? setHeaderValue(field.key, v2)
                              : setBodyValue(field.key, v2);
                        },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.personasResponsableInspeccion:
              {
                final personasAsync = ref.watch(
                  catalogPersonasResponsableInspeccionActivasProvider,
                );

                return personasAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando responsables de inspección',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final options = _personOptionsFromDrift(list);
                    final v = value?.toString();
                    final exists = options.any((it) => it.value == v);

                    return withReference(
                      _searchableCatalogField(
                        label: field.label,
                        options: options,
                        value: (v != null && exists) ? v : null,
                        helperText: options.isEmpty
                            ? 'Sin responsables de inspección sincronizados'
                            : null,
                        enabled: !fieldReadOnly,
                        onChanged: (v2) {
                          isHeader
                              ? setHeaderValue(field.key, v2)
                              : setBodyValue(field.key, v2);
                        },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.personasJornal:
              {
                final personasAsync = ref.watch(
                  personasActivasByTipoCodigoProvider('JOR'),
                );

                return personasAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando jornaleros',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final options = _personOptionsFromDrift(list);
                    final v = value?.toString();
                    final exists = options.any((it) => it.value == v);

                    return withReference(
                      _searchableCatalogField(
                        label: field.label,
                        options: options,
                        value: (v != null && exists) ? v : null,
                        helperText: options.isEmpty
                            ? 'Sin jornaleros sincronizados'
                            : null,
                        enabled: !fieldReadOnly,
                        onChanged: (v2) {
                          isHeader
                              ? setHeaderValue(field.key, v2)
                              : setBodyValue(field.key, v2);
                        },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.topicoEmpresas:
              {
                final empresasAsync = ref.watch(catalogTopicoEmpresasProvider);

                return empresasAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando empresas',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final options = _topicoEmpresaOptionsFromDrift(list);
                    final v = value?.toString();
                    final exists = options.any((it) => it.value == v);

                    return withReference(
                      _searchableDriftCatalogField(
                        controlKey: 'topico-empresa-${field.key}',
                        label: field.label,
                        options: options,
                        value: (v != null && exists) ? v : null,
                        helperText: options.isEmpty
                            ? 'Sin empresas sincronizadas'
                            : null,
                        enabled: !fieldReadOnly,
                        onChanged: (v2) {
                          isHeader
                              ? setHeaderValue(field.key, v2)
                              : setBodyValue(field.key, v2);
                        },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.topicoPacientes:
              {
                void applyPaciente(dynamic selected) {
                  setBodyValues({
                    field.key: _topicoPacienteNullableText(selected, const [
                      'idCodigoGeneral',
                      'id_codigo_general',
                      'IDCODIGOGENERAL',
                    ]),
                    'pacienteNombre': _topicoPacienteNullableText(
                      selected,
                      const [
                        'nombreCompleto',
                        'nombre_completo',
                        'NOMBRE_COMPLETO',
                      ],
                    ),
                    'dni': _topicoPacienteNullableText(selected, const [
                      'dni',
                      'DNI',
                    ]),
                    'genero': _topicoPacienteGeneroLabel(selected),
                    'planilla': _topicoPacienteNullableText(selected, const [
                      'planilla',
                      'PLANILLA',
                    ]),
                    'cargo': _topicoPacienteNullableText(selected, const [
                      'cargo',
                      'CARGO',
                    ]),
                    'area': _topicoPacienteNullableText(selected, const [
                      'area',
                      'AREA',
                    ]),
                  });
                }

                return withReference(
                  _TopicoPacienteSearchField(
                    controlKey: 'topico-paciente-${field.key}',
                    label: field.label,
                    value: value?.toString(),
                    initialText: getBodyValue('pacienteNombre')?.toString(),
                    enabled: !fieldReadOnly,
                    onSelected: fieldReadOnly ? null : applyPaciente,
                  ),
                  currentValue: value,
                );
              }

            case CartillaCatalogSource.topicoConsultas:
              {
                final consultasAsync = ref.watch(
                  catalogTopicoConsultasProvider,
                );

                return consultasAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando consultas',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final options = _topicoConsultaOptionsFromDrift(list);
                    final v = value?.toString();
                    final exists = options.any((it) => it.value == v);

                    return withReference(
                      _searchableDriftCatalogField(
                        controlKey: 'topico-consulta-${field.key}',
                        label: field.label,
                        options: options,
                        value: (v != null && exists) ? v : null,
                        helperText: options.isEmpty
                            ? 'Sin consultas sincronizadas'
                            : null,
                        enabled: !fieldReadOnly,
                        onChanged: (v2) {
                          isHeader
                              ? setHeaderValue(field.key, v2)
                              : setBodyValue(field.key, v2);
                        },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.topicoMedicamentos:
              {
                final medicamentosAsync = ref.watch(
                  catalogTopicoMedicamentosProvider,
                );

                return medicamentosAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando medicamentos',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    final options = _topicoMedicamentoOptionsFromDrift(list);
                    if (config.templateKey ==
                            CartillaTopicoConfig.templateKeyStatic &&
                        field.key == CartillaTopicoConfig.kMedicamento) {
                      return withReference(
                        _TopicoMedicamentosField(
                          label: field.label,
                          options: options,
                          value: value,
                          helperText: options.isEmpty
                              ? 'Sin medicamentos sincronizados'
                              : null,
                          enabled: !fieldReadOnly,
                          onChanged: (items) {
                            isHeader
                                ? setHeaderValue(field.key, items)
                                : setBodyValue(field.key, items);
                          },
                        ),
                        currentValue: value,
                      );
                    }

                    final v = value?.toString();
                    final exists = options.any((it) => it.value == v);

                    return withReference(
                      _searchableDriftCatalogField(
                        controlKey: 'topico-medicamento-${field.key}',
                        label: field.label,
                        options: options,
                        value: (v != null && exists) ? v : null,
                        helperText: options.isEmpty
                            ? 'Sin medicamentos sincronizados'
                            : null,
                        enabled: !fieldReadOnly,
                        onChanged: (v2) {
                          isHeader
                              ? setHeaderValue(field.key, v2)
                              : setBodyValue(field.key, v2);
                        },
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.orillasPorLote:
              {
                // Solo muestra orillas cuando fenología = ORILLA. Si INTERIOR: vacío.
                final fenologia = getBodyValue(
                  CartillaBrixConfig.kFenologia,
                )?.toString();
                final loteIdRaw = getHeaderValue(
                  field.dependsOnHeaderKey ?? 'loteId',
                );
                final loteId = loteIdRaw != null
                    ? int.tryParse(loteIdRaw.toString())
                    : null;

                if (fenologia != 'ORILLA' || loteId == null || loteId <= 0) {
                  // Fenología INTERIOR o sin lote: dropdown vacío y deshabilitado
                  return withReference(
                    DropdownButtonFormField<String>(
                      key: ValueKey<String>('brix-detalle-$fenologia-$loteId'),
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: fenologia == 'INTERIOR'
                            ? 'Solo aplica cuando Fenología = ORILLA'
                            : 'Seleccione un lote primero',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  );
                }

                final orillasAsync = ref.watch(orillasByLoteProvider(loteId));

                return orillasAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando orillas',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    // Construir items únicos por idLoteOrilla y label \"orilla_label - perimetral_descripcion\"
                    final seen = <String>{};
                    final idToLabel = <String, String>{};
                    final items = <DropdownMenuItem<String>>[];

                    for (final x in list) {
                      Map<String, dynamic> m;
                      try {
                        m = (x as dynamic).toJson().cast<String, dynamic>();
                      } catch (_) {
                        continue;
                      }

                      final idRaw =
                          m['idLoteOrilla'] ?? m['loteOrillaId'] ?? m['id'];
                      if (idRaw == null) continue;
                      final id = idRaw.toString();
                      if (seen.contains(id)) continue;
                      seen.add(id);

                      final label = (m['orillaLabel'] ?? '').toString();
                      final perimetral = (m['perimetralDescripcion'] ?? '')
                          .toString();
                      final text = perimetral.isNotEmpty
                          ? '$label - $perimetral'
                          : label;

                      idToLabel[id] = text;
                      items.add(
                        DropdownMenuItem(
                          value: id,
                          child: _orillaDropdownMenuItemChild(text),
                        ),
                      );
                    }

                    final v = value?.toString();
                    final exists = items.any((it) => it.value == v);

                    final size = MediaQuery.sizeOf(context);
                    // [DropdownButtonFormField] en Flutter 3.32 no expone [menuWidth]; el menú
                    // quedaba tan ancho como el campo y cortaba textos largos. [DropdownButton]
                    // sí permite un menú más ancho (casi pantalla completa).
                    final menuW = (size.width - 20).clamp(280.0, size.width);

                    return withReference(
                      InputDecorator(
                        decoration: InputDecoration(labelText: field.label),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            key: ValueKey<String>(
                              'brix-detalle-orilla-$loteId',
                            ),
                            isExpanded: true,
                            isDense: false,
                            value: (v != null && exists) ? v : null,
                            items: items,
                            menuWidth: menuW,
                            menuMaxHeight: size.height * 0.55,
                            itemHeight: 112,
                            selectedItemBuilder: (ctx) {
                              return items.map((it) {
                                final id = it.value;
                                final label = idToLabel[id] ?? id ?? '';
                                return _orillaDropdownSelectedLabel(label);
                              }).toList();
                            },
                            onChanged: fieldReadOnly
                                ? null
                                : (v2) {
                                    setBodyValue(field.key, v2);
                                    for (final s in config.sections) {
                                      for (final f in s.fields) {
                                        if (f.dependsOnHeaderKey == field.key) {
                                          setHeaderValue(f.key, null);
                                        }
                                      }
                                    }
                                  },
                          ),
                        ),
                      ),
                      currentValue: value,
                    );
                  },
                );
              }

            case CartillaCatalogSource.lotes:
              {
                final lotesAsync = ref.watch(catalogLotesProvider);

                return lotesAsync.when(
                  loading: () => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(labelText: field.label),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  error: (e, st) => withReference(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: null,
                      decoration: InputDecoration(
                        labelText: field.label,
                        helperText: 'Error cargando lotes',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    currentValue: value,
                  ),
                  data: (list) {
                    debugPrint('🟧 LOTES provider count=${list.length}');

                    final options = _loteOptionsFromDrift(list);
                    const templatesWithAutoVariedad = {
                      'cartilla_brotacion',
                      'cartilla_clasificacion_cargadores',
                      'cartilla_conteo_cargadores',
                      'cartilla_conteo_racimos',
                      'cartilla_floracion_cuaja',
                      'cartilla_labor_desbrote',
                      'cartilla_packing_descarte_calidad',
                      'cartilla_packing_recepcion',
                      'cartilla_poda',
                      'cartilla_preraleo',
                      'cartilla_raleo',
                    };

                    final shouldAutoCompleteVariedad =
                        isHeader &&
                        field.key == 'loteId' &&
                        templatesWithAutoVariedad.contains(config.templateKey);
                    final shouldAutoCompleteCultivo =
                        isHeader &&
                        field.key == 'loteId' &&
                        config.templateKey == 'cartilla_topico';
                    final shouldAutoCompleteFundo =
                        isHeader &&
                        field.key == 'loteId' &&
                        config.templateKey == 'cartilla_observaciones_campo';

                    dynamic resolveVariedadValueFromLote(String? loteId) {
                      if (loteId == null) return null;
                      for (final x in list) {
                        try {
                          final m = (x as dynamic)
                              .toJson()
                              .cast<String, dynamic>();
                          final idLoteRaw = m['idLote'] ?? m['ID_LOTE'];
                          if ('$idLoteRaw' != loteId) continue;
                          final idVarRaw = m['idVariedad'] ?? m['ID_VARIEDAD'];
                          if (idVarRaw != null &&
                              idVarRaw.toString().isNotEmpty) {
                            return idVarRaw.toString();
                          }
                          return null;
                        } catch (_) {
                          continue;
                        }
                      }
                      return null;
                    }

                    dynamic resolveCultivoValueFromLote(String? loteId) {
                      if (loteId == null) return null;
                      for (final x in list) {
                        try {
                          final m = (x as dynamic)
                              .toJson()
                              .cast<String, dynamic>();
                          final idLoteRaw = m['idLote'] ?? m['ID_LOTE'];
                          if ('$idLoteRaw' != loteId) continue;
                          final cultivo = m['cultivo'] ?? m['CULTIVO'];
                          return cultivo?.toString();
                        } catch (_) {
                          continue;
                        }
                      }
                      return null;
                    }

                    dynamic resolveFundoValueFromLote(String? loteId) {
                      if (loteId == null) return null;
                      for (final x in list) {
                        try {
                          final m = (x as dynamic)
                              .toJson()
                              .cast<String, dynamic>();
                          final idLoteRaw = m['idLote'] ?? m['ID_LOTE'];
                          if ('$idLoteRaw' != loteId) continue;
                          final fundo = m['idFundo'] ?? m['ID_FUNDO'];
                          return fundo?.toString();
                        } catch (_) {
                          continue;
                        }
                      }
                      return null;
                    }

                    void applyLoteSelection(
                      String? loteId, {
                      double? lat,
                      double? lon,
                    }) {
                      if (!shouldAutoCompleteVariedad &&
                          !shouldAutoCompleteCultivo &&
                          !shouldAutoCompleteFundo) {
                        if (lat != null) setHeaderValue('lat', lat);
                        if (lon != null) setHeaderValue('lon', lon);
                        isHeader
                            ? setHeaderValue(field.key, loteId)
                            : setBodyValue(field.key, loteId);
                        return;
                      }

                      dynamic next = currentPayload;
                      if (lat != null) {
                        next = (next as dynamic).setHeaderValue('lat', lat);
                      }
                      if (lon != null) {
                        next = (next as dynamic).setHeaderValue('lon', lon);
                      }
                      next = (next as dynamic).setHeaderValue(
                        field.key,
                        loteId,
                      );
                      if (shouldAutoCompleteVariedad) {
                        next = (next as dynamic).setBodyValue(
                          'variedad',
                          resolveVariedadValueFromLote(loteId),
                        );
                      }
                      if (shouldAutoCompleteCultivo) {
                        next = (next as dynamic).setBodyValue(
                          'cultivo',
                          resolveCultivoValueFromLote(loteId),
                        );
                      }
                      if (shouldAutoCompleteFundo) {
                        next = (next as dynamic).setBodyValue(
                          'fundo',
                          resolveFundoValueFromLote(loteId),
                        );
                      }
                      commitPayload(next);
                    }

                    final v = value?.toString();
                    final exists = options.any((it) => it.value == v);

                    final dropdown = _searchableDriftCatalogField(
                      controlKey: 'lote-dropdown-${field.key}',
                      label: field.label,
                      options: options,
                      value: (v != null && exists) ? v : null,
                      helperText: options.isEmpty
                          ? 'Sin lotes sincronizados'
                          : null,
                      enabled: !fieldReadOnly,
                      hintText: 'Buscar lote',
                      leadingIcon: Icons.search,
                      onChanged: fieldReadOnly
                          ? null
                          : (v2) => applyLoteSelection(v2),
                    );

                    // Si no es un dropdown de lote "especial", renderizamos solo el dropdown.
                    if (!isLoteDropdownField(field)) {
                      return withReference(dropdown, currentValue: value);
                    }

                    return withReference(
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: dropdown),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: OutlinedButton.icon(
                              icon: Icon(
                                Icons.my_location,
                                size: 18,
                                color: DonLuisColors.primary,
                              ),
                              label: const Text(''),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: DonLuisColors.primary,
                                side: BorderSide(
                                  color: DonLuisColors.primary.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              onPressed: fieldReadOnly
                                  ? null
                                  : () async {
                                      final locationService = ref.read(
                                        locationServiceProvider,
                                      );
                                      final geoResult = await locationService
                                          .tryGetGeoForLoteDetection();
                                      final geo = geoResult.geo;
                                      if (geo == null) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              geoResult.userMessage,
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final lat = (geo['lat'] as num)
                                          .toDouble();
                                      final lon = (geo['lon'] as num)
                                          .toDouble();

                                      final loteGeoService = ref.read(
                                        loteGeoServiceProvider,
                                      );
                                      final loteResult = await loteGeoService
                                          .detectLoteByLocationDetailed(
                                            lat: lat,
                                            lon: lon,
                                          );
                                      final lote = loteResult.lote;

                                      if (lote == null) {
                                        String message;
                                        switch (loteResult.failure) {
                                          case LoteDetectionFailure.noGeomData:
                                            message =
                                                'No hay lotes sincronizados con geometría disponible.';
                                            break;
                                          case LoteDetectionFailure
                                              .noBBoxCandidate:
                                          case LoteDetectionFailure
                                              .outsidePolygon:
                                          case null:
                                            message =
                                                'No se encontró lote para esta ubicación. Espera a que el GPS se estabilice y vuelve a intentar.';
                                            break;
                                        }
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(message)),
                                        );
                                        return;
                                      }

                                      final selectedId = lote.idLote.toString();
                                      applyLoteSelection(
                                        selectedId,
                                        lat: lat,
                                        lon: lon,
                                      );
                                    },
                            ),
                          ),
                        ],
                      ),
                      currentValue: value,
                    );
                  },
                );
              }
          }
        }

        // ✅ Dropdown estático (como tu versión actual)
        List<String> options = field.staticOptions ?? const [];
        final isFertilidadCatYema =
            config.templateKey == CartillaFertilidadConfig.templateKeyStatic &&
            CartillaFertilidadConfig.catYemaFieldKeys.contains(field.key);
        if (isFertilidadCatYema) {
          final ev = getBodyValue(CartillaFertilidadConfig.kEvaluacion);
          options = CartillaFertilidadConfig.catYemaOptionsForEvaluacion(ev);
        }
        final isGaritaFundo =
            isGaritaTemplate &&
            field.key == CartillaRegistroPersonalGaritaSeguridadConfig.kFundo;
        final isGaritaRetiro =
            _textValue(
              getBodyValue(
                CartillaRegistroPersonalGaritaSeguridadConfig.kMotivo,
              ),
            ).toUpperCase() ==
            'RETIRO';
        if (isGaritaFundo && isGaritaRetiro) {
          options = const [];
        }

        final vStr = value?.toString();
        final selected = (vStr != null && options.contains(vStr)) ? vStr : null;

        return withReference(
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: selected,
            decoration: InputDecoration(
              labelText: field.label,
              helperText: isGaritaFundo && isGaritaRetiro
                  ? 'No aplica cuando el motivo es RETIRO'
                  : options.isEmpty && isFertilidadCatYema
                  ? 'Sin opciones para esta evaluación'
                  : null,
            ),
            items: options
                .map(
                  (o) =>
                      DropdownMenuItem(value: o, child: _dropdownItemText(o)),
                )
                .toList(),
            onChanged: fieldReadOnly || options.isEmpty
                ? null
                : (v) {
                    if (isGaritaTemplate &&
                        field.key ==
                            CartillaRegistroPersonalGaritaSeguridadConfig
                                .kMotivo) {
                      dynamic next = currentPayload;
                      next = (next as dynamic).setBodyValue(
                        CartillaRegistroPersonalGaritaSeguridadConfig.kMotivo,
                        v,
                      );
                      if (_textValue(v).toUpperCase() == 'RETIRO') {
                        next = (next as dynamic).setBodyValue(
                          CartillaRegistroPersonalGaritaSeguridadConfig.kFundo,
                          null,
                        );
                      }
                      commitPayload(next);
                      return;
                    }
                    if (!isHeader &&
                        field.key == CartillaBrixConfig.kFenologia &&
                        config.templateKey ==
                            CartillaBrixConfig.templateKeyStatic &&
                        !CartillaBrixConfig.detalleFenologiaAplica(v)) {
                      // Una sola actualización: dos setBodyValue seguidos leían el mismo
                      // payload del build y la segunda pisaba la primera.
                      dynamic next = currentPayload;
                      next = (next as dynamic).setBodyValue(
                        CartillaBrixConfig.kFenologia,
                        v,
                      );
                      next = (next as dynamic).setBodyValue(
                        CartillaBrixConfig.kDetalleFenologia,
                        null,
                      );
                      commitPayload(next);
                      return;
                    }
                    isHeader
                        ? setHeaderValue(field.key, v)
                        : setBodyValue(field.key, v);
                  },
          ),
          currentValue: value,
        );
      }

    case CartillaFieldType.checkboxSiNo:
      {
        final value = isHeader
            ? getHeaderValue(field.key)
            : getBodyValue(field.key);
        final checked = _textValue(value).toUpperCase() == 'SI';
        return withReference(
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(field.label),
            value: checked,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: fieldReadOnly
                ? null
                : (selected) {
                    final nextValue = selected == true ? 'SI' : 'NO';
                    isHeader
                        ? setHeaderValue(field.key, nextValue)
                        : setBodyValue(field.key, nextValue);
                  },
          ),
          currentValue: value,
        );
      }

    case CartillaFieldType.multiSelectChips:
      final rawValue = isHeader
          ? getHeaderValue(field.key)
          : getBodyValue(field.key);
      final selectedValues = _asStringList(rawValue);
      final options = field.staticOptions ?? const [];

      return withReference(
        InputDecorator(
          decoration: InputDecoration(
            labelText: field.label,
            enabled: !fieldReadOnly,
          ),
          child: options.isEmpty
              ? const Text('Sin opciones')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in options)
                      FilterChip(
                        label: Text(option),
                        selected: selectedValues.contains(option),
                        onSelected: fieldReadOnly
                            ? null
                            : (selected) {
                                final nextValues = [...selectedValues];
                                if (selected) {
                                  if (!nextValues.contains(option)) {
                                    nextValues.add(option);
                                  }
                                } else {
                                  nextValues.remove(option);
                                }

                                if (isHeader) {
                                  setHeaderValue(field.key, nextValues);
                                } else {
                                  setBodyValue(field.key, nextValues);
                                }
                              },
                      ),
                  ],
                ),
        ),
        currentValue: selectedValues,
      );

    case CartillaFieldType.shortText:
      final txt =
          ((isHeader ? getHeaderValue(field.key) : getBodyValue(field.key))
              as String? ??
          '');
      return withReference(
        TextFormField(
          key: ValueKey(
            'short-text-${config.templateKey}-${field.key}-$fieldReadOnly',
          ),
          initialValue: txt,
          maxLines: 1,
          decoration: InputDecoration(labelText: field.label),
          readOnly: fieldReadOnly,
          enabled: !fieldReadOnly,
          onChanged: (v) => isHeader
              ? setHeaderValue(field.key, v)
              : setBodyValue(field.key, v),
        ),
        currentValue: txt,
      );

    case CartillaFieldType.date:
      {
        final value = isHeader
            ? getHeaderValue(field.key)
            : getBodyValue(field.key);
        final current = _textValue(value);
        return withReference(
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: fieldReadOnly
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _parseDatePe(current) ?? _nowPeru(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked == null) return;
                    final nextValue = _formatDatePe(picked);
                    isHeader
                        ? setHeaderValue(field.key, nextValue)
                        : setBodyValue(field.key, nextValue);
                  },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: field.label,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
              child: Text(
                current.isEmpty ? 'Seleccionar fecha' : current,
                style: current.isEmpty
                    ? TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.55),
                      )
                    : null,
              ),
            ),
          ),
          currentValue: value,
        );
      }

    case CartillaFieldType.time:
      {
        final value = isHeader
            ? getHeaderValue(field.key)
            : getBodyValue(field.key);
        final current = _textValue(value);
        return withReference(
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: fieldReadOnly
                ? null
                : () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime:
                          _parseTimePe(current) ??
                          TimeOfDay.fromDateTime(_nowPeru()),
                    );
                    if (picked == null) return;
                    final h = picked.hour.toString().padLeft(2, '0');
                    final m = picked.minute.toString().padLeft(2, '0');
                    final nextValue = '$h:$m';
                    isHeader
                        ? setHeaderValue(field.key, nextValue)
                        : setBodyValue(field.key, nextValue);
                  },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: field.label,
                suffixIcon: const Icon(Icons.schedule_outlined, size: 18),
              ),
              child: Text(
                current.isEmpty ? 'Seleccionar hora' : current,
                style: current.isEmpty
                    ? TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.55),
                      )
                    : null,
              ),
            ),
          ),
          currentValue: value,
        );
      }

    case CartillaFieldType.intNumber:
      final v = isHeader ? getHeaderValue(field.key) : getBodyValue(field.key);
      final initialIntText = switch (v) {
        null => '',
        int value when value == 0 => '',
        num value when value == 0 => '',
        String value when value.trim() == '0' => '',
        _ => v.toString(),
      };
      return withReference(
        TextFormField(
          initialValue: initialIntText,
          decoration: InputDecoration(labelText: field.label, hintText: '0'),
          readOnly: fieldReadOnly,
          enabled: !fieldReadOnly,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            if (field.rules.maxDigits != null)
              LengthLimitingTextInputFormatter(field.rules.maxDigits),
          ],
          onChanged: (txt) {
            final val = txt.isEmpty ? null : int.tryParse(txt);
            isHeader
                ? setHeaderValue(field.key, val)
                : setBodyValue(field.key, val);
          },
        ),
        currentValue: v,
      );

    case CartillaFieldType.decimalNumber:
      {
        final v = isHeader
            ? getHeaderValue(field.key)
            : getBodyValue(field.key);
        final initial = switch (v) {
          null => '',
          num value when value == 0 => '',
          String value when value.trim() == '0' || value.trim() == '0.0' => '',
          _ => (v is num ? v.toString() : v.toString()),
        };
        return withReference(
          TextFormField(
            initialValue: initial,
            decoration: InputDecoration(labelText: field.label, hintText: '0'),
            readOnly: fieldReadOnly,
            enabled: !fieldReadOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [_DecimalTextInputFormatter()],
            onChanged: (txt) {
              final trimmed = txt.trim();
              if (trimmed.isEmpty) {
                isHeader
                    ? setHeaderValue(field.key, null)
                    : setBodyValue(field.key, null);
                return;
              }
              final normalized = trimmed.replaceAll(',', '.');
              final val = double.tryParse(normalized);
              isHeader
                  ? setHeaderValue(field.key, val)
                  : setBodyValue(field.key, val);
            },
          ),
          currentValue: v,
        );
      }

    case CartillaFieldType.stepperInt:
      return withReference(
        NumericStepperField(
          label: field.label,
          value: getBodyInt(field.key).toDouble(),
          step: 1,
          min: (field.rules.minValue ?? 0).toDouble(),
          max: field.rules.maxValue?.toDouble(),
          readOnly: fieldReadOnly,
          onChanged: (d) => setBodyValue(field.key, d.round()),
        ),
        currentValue: getBodyValue(field.key),
      );

    case CartillaFieldType.longText:
      final txt = (getBodyValue(field.key) as String? ?? '');
      return withReference(
        TextFormField(
          initialValue: txt,
          maxLines: 4,
          decoration: InputDecoration(labelText: field.label),
          readOnly: fieldReadOnly,
          enabled: !fieldReadOnly,
          onChanged: (v) => setBodyValue(field.key, v),
        ),
        currentValue: txt,
      );

    case CartillaFieldType.signaturePad:
      {
        final value = isHeader
            ? getHeaderValue(field.key)
            : getBodyValue(field.key);
        return withReference(
          _signatureActionButton(
            context: context,
            label: field.label,
            value: value,
            readOnly: fieldReadOnly,
            onChanged: (signature) => isHeader
                ? setHeaderValue(field.key, signature)
                : setBodyValue(field.key, signature),
          ),
          currentValue: value,
        );
      }

    case CartillaFieldType.photo:
      {
        final slot = field.photoIndex ?? 0;
        final photoListKey = photoListBodyKeyOverride ?? 'fotos';

        // ✅ Leer fotos desde BODY como List<Map>
        final rawFotos = (getBodyValue(photoListKey) as List?) ?? const [];

        int slotOf(dynamic f) {
          if (f is Map) {
            final v = f['slot'];
            if (v is num) return v.toInt();
            return int.tryParse(v?.toString() ?? '') ?? -1;
          }
          return -1;
        }

        String? pathOf(dynamic f) {
          if (f is Map) return f['localPath'] as String?;
          return null;
        }

        final idx = rawFotos.indexWhere((f) => slotOf(f) == slot);
        final path = idx >= 0 ? pathOf(rawFotos[idx]) : null;

        List<Map<String, dynamic>> cloneAsMapList(List list) {
          return list
              .whereType<dynamic>()
              .map(
                (e) => (e is Map
                    ? Map<String, dynamic>.from(e)
                    : <String, dynamic>{}),
              )
              .where((m) => m.isNotEmpty)
              .toList();
        }

        final userId = ref.read(currentUserIdProvider);

        return PhotoSlotField(
          slot: slot,
          localPath: path,
          readOnly: fieldReadOnly,
          onCapture: () async {
            final r = await photoService.captureToSlot(
              localId: localId,
              slot: slot,
              userId: userId,
            );
            if (r == null) return;

            // Captura anterior con otro nombre de archivo: borrar para no llenar el disco.
            if (path != null && path.isNotEmpty && path != r.localPath) {
              try {
                final oldFile = File(path);
                if (await oldFile.exists()) await oldFile.delete();
              } catch (_) {}
            }

            // Si la ruta cambia o se reemplaza el mismo archivo: refrescar caché de imagen.
            imageCache.evict(FileImage(File(r.localPath)));

            final fotos = cloneAsMapList(rawFotos);
            final i = fotos.indexWhere((m) => slotOf(m) == slot);

            final item = <String, dynamic>{
              'slot': slot,
              'localPath': r.localPath,
              // opcional si manejas attachmentLocalId:
              // 'attachmentLocalId': r.attachmentLocalId,
            };

            if (i >= 0) {
              fotos[i] = item;
            } else {
              fotos.add(item);
            }

            // ✅ Esto dispara la UI + persiste en payload dinámico
            setBodyValue(photoListKey, fotos);
          },
          onRemove: () async {
            await photoService.deletePhoto(
              localId: localId,
              slot: slot,
              localPath: path,
            );

            final fotos = cloneAsMapList(rawFotos)
              ..removeWhere((m) => slotOf(m) == slot);

            // ✅ Esto actualiza UI + payload
            setBodyValue(photoListKey, fotos);
          },
        );
      }

    /*   case CartillaFieldType.photo: {
      final slot = field.photoIndex ?? 0;

      // tu payload guarda fotos como body.fotos (lista) o parecido
      // aquí uso el mismo patrón que normalmente se usa en tu proyecto:
      final fotos = (getBodyValue('fotos') as List?) ?? const [];
      final idx = fotos.indexWhere((f) {
        try {
          return (f as dynamic).slot == slot;
        } catch (_) {
          return false;
        }
      });

      final path = idx >= 0 ? (fotos[idx] as dynamic).localPath as String? : null;

      return PhotoSlotField(
        slot: slot,
        localPath: path,
        onCapture: () async {
          await photoService.captureToSlot(localId: localId, slot: slot);
        },
        onRemove: () async {
          await photoService.deleteSlot(localId: localId, slot: slot);
        },
      );

      return PhotoSlotField(
        slot: slot,
        localPath: path,
        onCapture: () async {
          final r = await photoService.captureToSlot(localId: localId, slot: slot);
          if (r == null) return;
          onUpdatePayload(payload.upsertFoto(slot: slot, localPath: r.localPath));
        },
        onRemove: () async {
          await photoService.deleteSlot(localId: localId, slot: slot);
          onUpdatePayload(payload.removeFoto(slot));
        },
      );
    }*/

    case CartillaFieldType.intReadOnly:
      {
        final v = getBodyValue(field.key);
        final text = (v == null) ? '' : v.toString();
        return InputDecorator(
          decoration: InputDecoration(
            labelText: field.label,
            suffixIcon: const Icon(Icons.lock_outline, size: 18),
          ),
          child: Text(text.isEmpty ? '-' : text),
        );
      }

    case CartillaFieldType.decimalReadOnly:
      {
        final v = getBodyValue(field.key);
        String text;
        if (v == null) {
          text = '';
        } else if (v is num) {
          text = v.toStringAsFixed(2);
        } else {
          text = v.toString();
        }
        return InputDecorator(
          decoration: InputDecoration(
            labelText: field.label,
            suffixIcon: const Icon(Icons.lock_outline, size: 18),
          ),
          child: Text(text.isEmpty ? '-' : text),
        );
      }
  }
}

Future<void> showValidationDialog(
  BuildContext context,
  List<ValidationIssue> issues,
) async {
  if (!context.mounted) return;

  final lines = issues
      .map((e) => '• ${e.sectionTitle}: ${e.fieldLabel}')
      .toList(growable: false);

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Faltan campos obligatorios'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Completa lo siguiente antes de Finalizar:'),
              const SizedBox(height: 12),
              ...lines.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(t),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
