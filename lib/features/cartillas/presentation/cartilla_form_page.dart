import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../../shared/widgets/donluis_section_card.dart';
import '../../../shared/widgets/donluis_app_bar.dart';
import '../../plantillas/fitosanidad/presentation/widgets/numeric_stepper_field.dart';
import '../application/cartilla_validator.dart';
import '../application/photo_service.dart';
import '../application/providers.dart';
import '../domain/cartilla_form_config.dart';
import '../domain/cartilla_form_models.dart';
import '../domain/cartilla_registry.dart';

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

class CartillaFormPage extends ConsumerWidget {
  final int localId;
  final CartillaFormConfig config;

  const CartillaFormPage({
    super.key,
    required this.localId,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final binding = CartillaRegistry.resolveBinding(config.templateKey);

    final st = binding.watchState(ref, localId);
    final nt = binding.readNotifier(ref, localId);
    final payload = st.payload;

    final photoService = ref.read(photoServiceProvider);

    final registroAsync = ref.watch(registroByLocalIdProvider(localId));
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

    return DonLuisGradientScaffold(
      appBar: DonLuisAppBar(
        title: Text(config.templateKey),
        actions: [
          // 💾 GUARDAR
          IconButton(
            tooltip: 'Guardar',
            onPressed: st.saving == true || isSyncedRecord
                ? null
                : () async {
              debugPrint('🟩 BEFORE save header.campaniaId=${getHeaderValue('campaniaId')}');
              debugPrint('🟩 BEFORE save header.loteId=${getHeaderValue('loteId')}');
              await nt.saveLocal();
              debugPrint('🟩 AFTER save');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Guardado')),
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
            onPressed: st.saving == true
                ? null
                : () async {
              await nt.saveLocal();
              final newLocalId = await nt.duplicateAsNew();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => CartillaFormPage(
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

          // ✅ FINALIZAR / VALIDAR
          IconButton(
            tooltip: 'Finalizar',
            onPressed: st.saving == true || isSyncedRecord
                ? null
                : () async {
              final issues = validateRequired(
                config: config,
                getHeaderValue: (k) => payload.getHeaderValue(k),
                getBodyValue: (k) => payload.getBodyValue(k),
              );

              if (issues.isNotEmpty) {
                await showValidationDialog(context, issues);
                return;
              }

              await nt.finalize();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registro marcado como LISTO para sincronizar'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_circle),
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
                  title: section.title,
                  icon: Icons.folder_outlined,
                  initiallyExpanded: true,
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
                            readOnly: isSyncedRecord,
                            getHeaderValue: getHeaderValue,
                            setHeaderValue: setHeaderValue,
                            getBodyValue: getBodyValue,
                            getBodyInt: getBodyInt,
                            setBodyValue: setBodyValue,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Barra inferior Guardar / Finalizar
          Container(
            decoration: BoxDecoration(
              color: DonLuisColors.surfaceCard,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
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
                        label: Text(st.saving == true ? 'Guardando...' : 'Guardar'),
                        onPressed: st.saving == true || isSyncedRecord
                            ? null
                            : () async {
                          await nt.saveLocal();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Guardado')),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DonLuisColors.secondary,
                        ),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Finalizar'),
                        onPressed: st.saving == true || isSyncedRecord
                            ? null
                            : () async {
                          final issues = validateRequired(
                            config: config,
                            getHeaderValue: (k) => payload.getHeaderValue(k),
                            getBodyValue: (k) => payload.getBodyValue(k),
                          );

                          if (issues.isNotEmpty) {
                            await showValidationDialog(context, issues);
                            return;
                          }

                          await nt.finalize();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registro marcado como LISTO para sincronizar'),
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
  required dynamic Function(String) getHeaderValue,
  required void Function(String, dynamic) setHeaderValue,
  required dynamic Function(String) getBodyValue,
  required int Function(String) getBodyInt,
  required void Function(String, dynamic) setBodyValue,
}) {
  final isHeader = config.headerKeys.contains(field.key);

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
              loading: () => DropdownButtonFormField<String>(
                isExpanded: true,
                value: null,
                decoration: InputDecoration(labelText: field.label),
                items: const [],
                onChanged: null,
              ),
              error: (e, st) => DropdownButtonFormField<String>(
                isExpanded: true,
                value: null,
                decoration: InputDecoration(
                  labelText: field.label,
                  helperText: 'Error cargando campañas',
                ),
                items: const [],
                onChanged: null,
              ),
              data: (list) {
                final items = _itemsFromDrift(list);
                final v = value?.toString();
                final exists = items.any((it) => it.value == v);

                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: (v != null && exists) ? v : null,
                  decoration: InputDecoration(labelText: field.label),
                  items: items,
                  onChanged: readOnly
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
                );
              },
            );
          }

          case CartillaCatalogSource.orillasPorLote: {
            // Solo muestra orillas cuando fenología = ORILLA. Si INTERIOR: vacío.
            final fenologia = getBodyValue('fenologia')?.toString();
            final loteIdRaw = getHeaderValue(field.dependsOnHeaderKey ?? 'loteId');
            final loteId = loteIdRaw != null
                ? int.tryParse(loteIdRaw.toString())
                : null;

            if (fenologia != 'ORILLA' || loteId == null || loteId <= 0) {
              // Fenología INTERIOR o sin lote: dropdown vacío y deshabilitado
              return DropdownButtonFormField<String>(
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
              );
            }

            final orillasAsync = ref.watch(orillasByLoteProvider(loteId));

            return orillasAsync.when(
              loading: () => DropdownButtonFormField<String>(
                isExpanded: true,
                value: null,
                decoration: InputDecoration(labelText: field.label),
                items: const [],
                onChanged: null,
              ),
              error: (e, st) => DropdownButtonFormField<String>(
                isExpanded: true,
                value: null,
                decoration: InputDecoration(
                  labelText: field.label,
                  helperText: 'Error cargando orillas',
                ),
                items: const [],
                onChanged: null,
              ),
              data: (list) {
                // Construir items únicos por idLoteOrilla y label \"orilla_label - perimetral_descripcion\"
                final seen = <String>{};
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

                  items.add(
                    DropdownMenuItem(
                      value: id,
                      child: _dropdownItemText(text),
                    ),
                  );
                }

                final v = value?.toString();
                final exists = items.any((it) => it.value == v);

                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: (v != null && exists) ? v : null,
                  decoration: InputDecoration(labelText: field.label),
                  items: items,
                  onChanged: readOnly
                      ? null
                      : (v2) {
                    setBodyValue(field.key, v2);
                    // Limpia dependientes si los hubiera
                    for (final s in config.sections) {
                      for (final f in s.fields) {
                        if (f.dependsOnHeaderKey == field.key) {
                          setHeaderValue(f.key, null);
                        }
                      }
                    }
                  },
                );
              },
            );
          }

          case CartillaCatalogSource.lotes: {
            final lotesAsync = ref.watch(catalogLotesProvider);

            return lotesAsync.when(
              loading: () => DropdownButtonFormField<String>(
                isExpanded: true,
                value: null,
                decoration: InputDecoration(labelText: field.label),
                items: const [],
                onChanged: null,
              ),
              error: (e, st) => DropdownButtonFormField<String>(
                isExpanded: true,
                value: null,
                decoration: InputDecoration(
                  labelText: field.label,
                  helperText: 'Error cargando lotes',
                ),
                items: const [],
                onChanged: null,
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
                  onChanged: readOnly
                      ? null
                      : (v2) => isHeader
                          ? setHeaderValue(field.key, v2)
                          : setBodyValue(field.key, v2),
                );

                // Si no es un dropdown de lote "especial", renderizamos solo el dropdown.
                if (!isLoteDropdownField(field)) {
                  return dropdown;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: dropdown),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.my_location, size: 18, color: DonLuisColors.primary),
                        label: const Text('Usar GPS'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DonLuisColors.primary,
                          side: BorderSide(color: DonLuisColors.primary.withOpacity(0.7)),
                        ),
                        onPressed: readOnly
                            ? null
                            : () async {
                        final locationService = ref.read(locationServiceProvider);
                        final geo = await locationService.tryGetHeaderGeo();
                        if (geo == null) {
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
                );
              },
            );
          }
        }
      }

      // ✅ Dropdown estático (como tu versión actual)
      final options = field.staticOptions ?? const [];
      return DropdownButtonFormField<String>(
        isExpanded: true,
        value: value as String?,
        decoration: InputDecoration(labelText: field.label),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: _dropdownItemText(o)))
            .toList(),
        onChanged: readOnly
            ? null
            : (v) {
          isHeader ? setHeaderValue(field.key, v) : setBodyValue(field.key, v);
          // BRIX: al cambiar fenología a INTERIOR, limpiar detalleFenologia
          if (!isHeader &&
              field.key == 'fenologia' &&
              v == 'INTERIOR' &&
              config.templateKey == 'cartilla_brix') {
            setBodyValue('detalleFenologia', null);
          }
        },
      );
    }

    case CartillaFieldType.intNumber:
      final v = isHeader ? getHeaderValue(field.key) : getBodyValue(field.key);
      return TextFormField(
        initialValue: v?.toString(),
        decoration: InputDecoration(labelText: field.label),
        readOnly: readOnly,
        enabled: !readOnly,
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
      );

    case CartillaFieldType.stepperInt:
      return NumericStepperField(
        label: field.label,
        value: getBodyInt(field.key).toDouble(),
        step: 1,
        min: (field.rules.minValue ?? 0).toDouble(),
        max: field.rules.maxValue?.toDouble(),
        readOnly: readOnly,
        onChanged: (d) => setBodyValue(field.key, d.round()),
      );

    case CartillaFieldType.longText:
      final txt = (getBodyValue(field.key) as String? ?? '');
      return TextFormField(
        initialValue: txt,
        maxLines: 4,
        decoration: InputDecoration(labelText: field.label),
        readOnly: readOnly,
        enabled: !readOnly,
        onChanged: (v) => setBodyValue(field.key, v),
      );

    case CartillaFieldType.photo: {
      final slot = field.photoIndex ?? 0;

      // ✅ Leer fotos desde BODY como List<Map>
      final rawFotos = (getBodyValue('fotos') as List?) ?? const [];

      int _slotOf(dynamic f) {
        if (f is Map) {
          final v = f['slot'];
          if (v is num) return v.toInt();
          return int.tryParse(v?.toString() ?? '') ?? -1;
        }
        return -1;
      }

      String? _pathOf(dynamic f) {
        if (f is Map) return f['localPath'] as String?;
        return null;
      }

      final idx = rawFotos.indexWhere((f) => _slotOf(f) == slot);
      final path = idx >= 0 ? _pathOf(rawFotos[idx]) : null;

      List<Map<String, dynamic>> _cloneAsMapList(List list) {
        return list
            .whereType<dynamic>()
            .map((e) => (e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}))
            .where((m) => m.isNotEmpty)
            .toList();
      }

      return PhotoSlotField(
        slot: slot,
        localPath: path,
        readOnly: readOnly,
        onCapture: () async {
          final r = await photoService.captureToSlot(localId: localId, slot: slot);
          if (r == null) return;

          final fotos = _cloneAsMapList(rawFotos);
          final i = fotos.indexWhere((m) => _slotOf(m) == slot);

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
          setBodyValue('fotos', fotos);
        },
        onRemove: () async {
          await photoService.deleteSlot(localId: localId, slot: slot);

          final fotos = _cloneAsMapList(rawFotos)
            ..removeWhere((m) => _slotOf(m) == slot);

          // ✅ Esto actualiza UI + payload
          setBodyValue('fotos', fotos);
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
