import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../../shared/widgets/donluis_section_card.dart';
import '../../../shared/widgets/donluis_app_bar.dart';
import '../../plantillas/brix/domain/cartilla_brix_config.dart';
import '../../plantillas/fertilidad/domain/cartilla_fertilidad_config.dart';
import '../../plantillas/fitosanidad/presentation/widgets/numeric_stepper_field.dart';
import '../../plantillas/poda/domain/cartilla_poda_config.dart';
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

String _textDataFromDropdownChild(Widget child) {
  if (child is Text) return child.data ?? '';
  return '';
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
      if (m.containsKey(k) && m[k] != null && '${m[k]}'.isNotEmpty) return '${m[k]}';
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
      if (m.containsKey(k) && m[k] != null && '${m[k]}'.isNotEmpty) return '${m[k]}';
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

String _comparativeSeedKey(int localId, int? referenceLocalId) =>
    '$localId::$referenceLocalId';

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
  if (value is Map) return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
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

Widget _referenceValueBox({
  required String value,
  required bool modified,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: DonLuisColors.surfaceCard.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: DonLuisColors.primary.withValues(alpha: 0.10),
      ),
    ),
    child: Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Inicial: $value',
          style: const TextStyle(fontSize: 12),
        ),
        if (modified)
          const Chip(
            label: Text('Modificado'),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            labelPadding: EdgeInsets.symmetric(horizontal: 2),
          ),
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
  if (!comparativeMode || fieldReadOnly || _isComparativeTechnicalField(field)) {
    return child;
  }

  final referenceValue = getReferenceHeaderValue != null || getReferenceBodyValue != null
      ? (getReferenceHeaderValue?.call(field.key) ?? getReferenceBodyValue?.call(field.key))
      : null;

  if (!_hasReferenceValue(referenceValue)) return child;

  final initialText = _referenceDisplayValue(referenceValue);
  if (initialText.isEmpty) return child;

  final modified = _hasEditedComparativeValue(currentValue) &&
      _comparableValue(currentValue) != _comparableValue(referenceValue);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _referenceValueBox(value: initialText, modified: modified),
      child,
    ],
  );
}

class CartillaFormPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final binding = CartillaRegistry.resolveBinding(config.templateKey);
    final isPoda = config.templateKey == CartillaPodaConfig.templateKeyStatic;
    final usePodaFinalMode = isPoda && podaFinalMode;

    final st = binding.watchState(ref, localId);
    final nt = binding.readNotifier(ref, localId);
    final payload = st.payload;

    final photoService = ref.read(photoServiceProvider);

    final registroAsync = ref.watch(registroByLocalIdProvider(localId));
    final referenceRegistroAsync = comparativeMode && referenceLocalId != null
        ? ref.watch(registroByLocalIdProvider(referenceLocalId!))
        : const AsyncValue<Registro?>.data(null);
    // Consideramos \"sincronizado\" si ya tiene serverId asignado.
    final isSyncedRecord = registroAsync.maybeWhen(
      data: (reg) => reg.serverId != null,
      orElse: () => false,
    );

    if (st.loading == true) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    dynamic getHeaderValue(String key) {
      return (st.payload as dynamic).getHeaderValue(key);
    }

    void setHeaderValue(String key, dynamic value) {
      final nextPayload = (st.payload as dynamic).setHeaderValue(key, value);
      nt.update(nextPayload);
    }

    dynamic getBodyValue(String key) {
      return (st.payload as dynamic).getBodyValue(key);
    }

    void setBodyValue(String key, dynamic value) {
      final nextPayload = (st.payload as dynamic).setBodyValue(key, value);
      nt.update(nextPayload);
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

    final shouldSeedComparativePayload = comparativeMode &&
        referenceLocalId != null &&
        referenceLocalId != localId &&
        referencePayload != null &&
        !_comparativeSeededForms
            .contains(_comparativeSeedKey(localId, referenceLocalId));

    if (shouldSeedComparativePayload) {
      final refHeader = Map<String, dynamic>.from(
        (referencePayload['header'] as Map?)?.cast<String, dynamic>() ?? const {},
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

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DonLuisGradientScaffold(
      appBar: DonLuisAppBar(
        title: Text(
          usePodaFinalMode ? '${config.templateKey} · final' : config.templateKey,
        ),
        actions: [
          // 💾 GUARDAR (valida + listo para sincronizar)
          IconButton(
            tooltip: 'Guardar (listo para sincronizar)',
            onPressed: st.saving == true || isSyncedRecord
                ? null
                : () async {
              final issues = validateRequired(
                config: config,
                getHeaderValue: (k) => payload.getHeaderValue(k),
                getBodyValue: getValidationBodyValue,
              );

              if (issues.isNotEmpty) {
                await showValidationDialog(context, issues);
                return;
              }

              debugPrint('🟩 BEFORE save header.campaniaId=${getHeaderValue('campaniaId')}');
              debugPrint('🟩 BEFORE save header.loteId=${getHeaderValue('loteId')}');

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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: config.sections.length,
              itemBuilder: (_, idx) {
                final section = config.sections[idx];
                return DonLuisSectionCard(
                  key: ValueKey<String>('cartilla-$localId-${section.key}'),
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
                            getBodyValue: usePodaFinalMode &&
                                    CartillaPodaConfig.isComparativeSection(
                                      section.key,
                                    )
                                ? (k) => getBodyValue(
                                      CartillaPodaConfig.finalBodyKey(k),
                                    )
                                : getBodyValue,
                            getBodyInt: usePodaFinalMode &&
                                    CartillaPodaConfig.isComparativeSection(
                                      section.key,
                                    )
                                ? (k) => getPodaBodyInt(
                                      CartillaPodaConfig.finalBodyKey(k),
                                    )
                                : getBodyInt,
                            setBodyValue: usePodaFinalMode &&
                                    CartillaPodaConfig.isComparativeSection(
                                      section.key,
                                    )
                                ? (k, v) => setBodyValue(
                                      CartillaPodaConfig.finalBodyKey(k),
                                      v,
                                    )
                                : setBodyValue,
                            getReferenceBodyValue: usePodaFinalMode &&
                                    CartillaPodaConfig.isComparativeSection(
                                      section.key,
                                    )
                                ? getBodyValue
                                : getReferenceBodyValue,
                            getReferenceHeaderValue: getReferenceHeaderValue,
                            comparativeMode: usePodaFinalMode
                                ? CartillaPodaConfig.isComparativeSection(
                                    section.key,
                                  )
                                : comparativeMode,
                            photoListBodyKeyOverride: usePodaFinalMode &&
                                    section.key ==
                                        CartillaPodaConfig.kSectionCalificacion
                                ? CartillaPodaConfig.kFinalFotos
                                : null,
                            readOnly: isSyncedRecord ||
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
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                            st.saving == true ? 'Guardando...' : 'Guardar'),
                        onPressed: st.saving == true || isSyncedRecord
                            ? null
                            : () async {
                          final issues = validateRequired(
                            config: config,
                            getHeaderValue: (k) => payload.getHeaderValue(k),
                            getBodyValue: getValidationBodyValue,
                          );

                          if (issues.isNotEmpty) {
                            await showValidationDialog(context, issues);
                            return;
                          }

                          // 1) Guardar usando la lógica específica de la cartilla
                          await nt.saveLocal();

                          // 2) Marcar listo para sincronizar
                          final local = ref.read(registrosLocalDSProvider);
                          await local.markAsReadyForSync(localId);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Guardado y listo para sincronizar'),
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
  dynamic Function(String)? getReferenceBodyValue,
  dynamic Function(String)? getReferenceHeaderValue,
  bool comparativeMode = false,
  String? photoListBodyKeyOverride,
}) {
  final fieldReadOnly = readOnly || field.rules.readOnly;
  final isHeader = config.headerKeys.contains(field.key);

  Widget withReference(Widget child, {dynamic currentValue}) {
    return _wrapFieldWithReference(
      field: field,
      comparativeMode: comparativeMode,
      fieldReadOnly: fieldReadOnly,
      currentValue: currentValue,
      getReferenceBodyValue: getReferenceBodyValue,
      getReferenceHeaderValue:
          isHeader ? getReferenceHeaderValue : null,
      child: child,
    );
  }

  bool isLoteDropdownField(CartillaFieldConfig f) {
    if (f.catalogSource == CartillaCatalogSource.lotes) return true;
    const loteKeys = {'loteId', 'id_lote', 'idLote'};
    return loteKeys.contains(f.key);
  }

  switch (field.type) {
    case CartillaFieldType.dropdown: {
      final value = isHeader ? getHeaderValue(field.key) : getBodyValue(field.key);

      // ✅ Dropdown dinámico por catálogo
      if (field.catalogSource != null) {
        switch (field.catalogSource!) {
          case CartillaCatalogSource.campanias: {
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
                      helperText:
                          items.isEmpty ? 'Sin campañas sincronizadas' : null,
                    ),
                    items: items,
                    onChanged: fieldReadOnly
                        ? null
                        : (v2) {
                      isHeader ? setHeaderValue(field.key, v2) : setBodyValue(field.key, v2);

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

          case CartillaCatalogSource.variedades: {
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
                      isHeader ? setHeaderValue(field.key, v2) : setBodyValue(field.key, v2);
                    },
                  ),
                  currentValue: value,
                );
              },
            );
          }

          case CartillaCatalogSource.orillasPorLote: {
            // Solo muestra orillas cuando fenología = ORILLA. Si INTERIOR: vacío.
            final fenologia =
                getBodyValue(CartillaBrixConfig.kFenologia)?.toString();
            final loteIdRaw = getHeaderValue(field.dependsOnHeaderKey ?? 'loteId');
            final loteId = loteIdRaw != null
                ? int.tryParse(loteIdRaw.toString())
                : null;

            if (fenologia != 'ORILLA' || loteId == null || loteId <= 0) {
              // Fenología INTERIOR o sin lote: dropdown vacío y deshabilitado
              return withReference(
                DropdownButtonFormField<String>(
                  key: ValueKey<String>(
                      'brix-detalle-$fenologia-$loteId'),
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

                  final idRaw = m['idLoteOrilla'] ?? m['loteOrillaId'] ?? m['id'];
                  if (idRaw == null) continue;
                  final id = idRaw.toString();
                  if (seen.contains(id)) continue;
                  seen.add(id);

                  final label = (m['orillaLabel'] ?? '').toString();
                  final perimetral = (m['perimetralDescripcion'] ?? '').toString();
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
                        key: ValueKey<String>('brix-detalle-orilla-$loteId'),
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

          case CartillaCatalogSource.lotes: {
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

                final items = _itemsFromDrift(list); // ✅ todos los lotes

                final v = value?.toString();
                final exists = items.any((it) => it.value == v);

                final dropdown = DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: (v != null && exists) ? v : null,
                  decoration: InputDecoration(labelText: field.label),
                  items: items,
                  onChanged: fieldReadOnly
                      ? null
                      : (v2) {
                    // Brotación / Clasificación Cargadores / Conteo Cargadores / Conteo Racimos:
                    // al cambiar lote, autocompletar variedad con idVariedad del lote.
                    if (isHeader &&
                        field.key == 'loteId' &&
                        (config.templateKey == 'cartilla_brotacion' ||
                            config.templateKey ==
                                'cartilla_clasificacion_cargadores' ||
                            config.templateKey ==
                                'cartilla_conteo_cargadores' ||
                            config.templateKey ==
                                'cartilla_conteo_racimos' ||
                            config.templateKey ==
                                'cartilla_labor_desbrote' ||
                            config.templateKey == 'cartilla_poda')) {
                      dynamic variedadValue;
                      if (v2 != null) {
                        for (final x in list) {
                          try {
                            final m =
                                (x as dynamic).toJson().cast<String, dynamic>();
                            final idLoteRaw = m['idLote'] ?? m['ID_LOTE'];
                            if ('$idLoteRaw' != v2) continue;
                            final idVarRaw =
                                m['idVariedad'] ?? m['ID_VARIEDAD'];
                            if (idVarRaw != null &&
                                idVarRaw.toString().isNotEmpty) {
                              variedadValue = idVarRaw.toString();
                            }
                            break;
                          } catch (_) {
                            continue;
                          }
                        }
                      }

                      // Un solo commit para no pisar cambios entre header/body.
                      dynamic next = currentPayload;
                      next = (next as dynamic).setHeaderValue(field.key, v2);
                      next =
                          (next as dynamic).setBodyValue('variedad', variedadValue);
                      commitPayload(next);
                      return;
                    }

                    isHeader ? setHeaderValue(field.key, v2) : setBodyValue(field.key, v2);
                  },
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
                          icon: Icon(Icons.my_location, size: 18, color: DonLuisColors.primary),
                          label: const Text(''),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DonLuisColors.primary,
                            side: BorderSide(color: DonLuisColors.primary.withValues(alpha: 0.7)),
                          ),
                          onPressed: fieldReadOnly
                              ? null
                              : () async {
                          final locationService = ref.read(locationServiceProvider);
                          final geo = await locationService.tryGetHeaderGeo();
                          if (geo == null) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No se pudo obtener ubicación GPS')),
                            );
                            return;
                          }

                          final lat = (geo['lat'] as num).toDouble();
                          final lon = (geo['lon'] as num).toDouble();

                          final loteGeoService = ref.read(loteGeoServiceProvider);
                          final lote = await loteGeoService.detectLoteByLocation(
                            lat: lat,
                            lon: lon,
                          );

                          if (lote == null) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se encontró lote para esta ubicación'),
                              ),
                            );
                            return;
                          }

                          // Actualiza header.lat/lon y el campo de lote.
                          setHeaderValue('lat', lat);
                          setHeaderValue('lon', lon);

                          final selectedId = lote.idLote.toString();
                          if (isHeader) {
                            setHeaderValue(field.key, selectedId);
                          } else {
                            setBodyValue(field.key, selectedId);
                          }
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
      final isFertilidadCatYema = config.templateKey ==
              CartillaFertilidadConfig.templateKeyStatic &&
          CartillaFertilidadConfig.catYemaFieldKeys.contains(field.key);
      if (isFertilidadCatYema) {
        final ev = getBodyValue(CartillaFertilidadConfig.kEvaluacion);
        options = CartillaFertilidadConfig.catYemaOptionsForEvaluacion(ev);
      }

      final vStr = value?.toString();
      final selected =
          (vStr != null && options.contains(vStr)) ? vStr : null;

      return withReference(
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: selected,
          decoration: InputDecoration(
            labelText: field.label,
            helperText: options.isEmpty && isFertilidadCatYema
                ? 'Sin opciones para esta evaluación'
                : null,
          ),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: _dropdownItemText(o)))
              .toList(),
          onChanged: fieldReadOnly || options.isEmpty
              ? null
              : (v) {
            if (!isHeader &&
                field.key == CartillaBrixConfig.kFenologia &&
                config.templateKey == CartillaBrixConfig.templateKeyStatic &&
                !CartillaBrixConfig.detalleFenologiaAplica(v)) {
              // Una sola actualización: dos setBodyValue seguidos leían el mismo
              // payload del build y la segunda pisaba la primera.
              dynamic next = currentPayload;
              next =
                  (next as dynamic).setBodyValue(CartillaBrixConfig.kFenologia, v);
              next = (next as dynamic)
                  .setBodyValue(CartillaBrixConfig.kDetalleFenologia, null);
              commitPayload(next);
              return;
            }
            isHeader ? setHeaderValue(field.key, v) : setBodyValue(field.key, v);
          },
        ),
        currentValue: value,
      );
    }

    case CartillaFieldType.shortText:
      final txt = ((isHeader ? getHeaderValue(field.key) : getBodyValue(field.key))
              as String? ??
          '');
      return withReference(
        TextFormField(
          initialValue: txt,
          maxLines: 1,
          decoration: InputDecoration(labelText: field.label),
          readOnly: fieldReadOnly,
          enabled: !fieldReadOnly,
          onChanged: (v) =>
              isHeader ? setHeaderValue(field.key, v) : setBodyValue(field.key, v),
        ),
        currentValue: txt,
      );

    case CartillaFieldType.intNumber:
      final v = isHeader ? getHeaderValue(field.key) : getBodyValue(field.key);
      return withReference(
        TextFormField(
          initialValue: v?.toString(),
          decoration: InputDecoration(labelText: field.label),
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
            isHeader ? setHeaderValue(field.key, val) : setBodyValue(field.key, val);
          },
        ),
        currentValue: v,
      );

    case CartillaFieldType.decimalNumber: {
      final v = isHeader ? getHeaderValue(field.key) : getBodyValue(field.key);
      final initial = (v == null)
          ? ''
          : (v is num ? v.toString() : v.toString());
      return withReference(
        TextFormField(
          initialValue: initial,
          decoration: InputDecoration(labelText: field.label),
          readOnly: fieldReadOnly,
          enabled: !fieldReadOnly,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [_DecimalTextInputFormatter()],
          onChanged: (txt) {
            final trimmed = txt.trim();
            if (trimmed.isEmpty) {
              isHeader ? setHeaderValue(field.key, null) : setBodyValue(field.key, null);
              return;
            }
            final normalized = trimmed.replaceAll(',', '.');
            final val = double.tryParse(normalized);
            isHeader ? setHeaderValue(field.key, val) : setBodyValue(field.key, val);
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

    case CartillaFieldType.photo: {
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
            .map((e) => (e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}))
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
          if (path != null &&
              path.isNotEmpty &&
              path != r.localPath) {
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

    case CartillaFieldType.intReadOnly: {
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

    case CartillaFieldType.decimalReadOnly: {
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
