import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../plantillas/fitosanidad/presentation/widgets/numeric_stepper_field.dart';
import '../../plantillas/fitosanidad/presentation/widgets/section_tile.dart';
import '../application/cartilla_validator.dart';
import '../application/photo_service.dart';
import '../application/providers.dart';
import '../domain/cartilla_form_config.dart';
import '../domain/cartilla_form_models.dart';
import '../domain/cartilla_registry.dart';

import '../presentation/widgets/photo_slot_field.dart';

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
    items.add(DropdownMenuItem(value: id, child: Text(label)));
  }

  // ordena por label
  items.sort((a, b) {
    final ta = (a.child as Text).data ?? '';
    final tb = (b.child as Text).data ?? '';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(config.templateKey),
        actions: [
          // 💾 GUARDAR
          IconButton(
            tooltip: 'Guardar',
            onPressed: st.saving == true
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
            onPressed: st.saving == true
                ? null
                : () async {
              final issues = validateRequired(
                config: config,
                getHeaderValue: (k) => payload.getHeaderValue(k),
                getBodyValue: (k) => payload.getBodyValue(k),
              );

              if (issues.isNotEmpty) {
                final msgs = issues
                    .map((i) => '${i.sectionTitle}: ${i.fieldLabel}')
                    .toList();
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
              padding: const EdgeInsets.all(12),
              itemCount: config.sections.length,
              itemBuilder: (_, idx) {
                final section = config.sections[idx];
                return SectionTile(
                  title: section.title,
                  child: Column(
                    children: [
                      for (final field in section.fields)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _renderField(
                            context: context,
                            ref: ref,
                            field: field,
                            config: config,
                            localId: localId,
                            photoService: photoService,
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

          // ✅ BOTONES AL FINAL
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      onPressed: st.saving == true
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
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Finalizar'),
                      onPressed: st.saving == true
                          ? null
                          : () async {
                        final issues = validateRequired(
                          config: config,
                          getHeaderValue: (k) => payload.getHeaderValue(k),
                          getBodyValue: (k) => payload.getBodyValue(k),
                        );

                        if (issues.isNotEmpty) {
                          final msgs = issues
                              .map((i) => '${i.sectionTitle}: ${i.fieldLabel}')
                              .toList();
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
  required dynamic Function(String) getHeaderValue,
  required void Function(String, dynamic) setHeaderValue,
  required dynamic Function(String) getBodyValue,
  required int Function(String) getBodyInt,
  required void Function(String, dynamic) setBodyValue,
}) {
  final isHeader = config.headerKeys.contains(field.key);

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
                value: null,
                decoration: InputDecoration(labelText: field.label),
                items: const [],
                onChanged: null,
              ),
              error: (e, st) => DropdownButtonFormField<String>(
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
                  value: (v != null && exists) ? v : null,
                  decoration: InputDecoration(labelText: field.label),
                  items: items,
                  onChanged: (v2) {
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

          case CartillaCatalogSource.lotes: {
            final lotesAsync = ref.watch(catalogLotesProvider);
            final depKey = field.dependsOnHeaderKey;
            final campId = depKey == null ? null : getHeaderValue(depKey)?.toString();

            return lotesAsync.when(
              loading: () => DropdownButtonFormField<String>(
                value: null,
                decoration: InputDecoration(labelText: field.label),
                items: const [],
                onChanged: null,
              ),
              error: (e, st) => DropdownButtonFormField<String>(
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
                final depKey = field.dependsOnHeaderKey;
                final campId = depKey == null ? null : getHeaderValue(depKey)?.toString();
                debugPrint('🟧 LOTES campId(dep=$depKey)=$campId');

                // log 1: ejemplo de primer lote (para ver llaves reales)
                if (list.isNotEmpty) {
                  try {
                    final m = (list.first as dynamic).toJson();
                    debugPrint('🟧 LOTES first.toJson keys=${(m as Map).keys.toList()}');
                    debugPrint('🟧 LOTES first.toJson=$m');
                  } catch (e) {
                    debugPrint('🟧 LOTES first.toJson ERROR=$e');
                  }
                }

                final items = _itemsFromDrift(list); // ✅ todos los lotes

                final v = value?.toString();
                final exists = items.any((it) => it.value == v);

                return DropdownButtonFormField<String>(
                  value: (v != null && exists) ? v : null,
                  decoration: InputDecoration(labelText: field.label),
                  items: items,
                  onChanged: (v2) => isHeader
                      ? setHeaderValue(field.key, v2)
                      : setBodyValue(field.key, v2),
                );
              },
            );
          }
        }
      }

      // ✅ Dropdown estático (como tu versión actual)
      final options = field.staticOptions ?? const [];
      return DropdownButtonFormField<String>(
        value: value as String?,
        decoration: InputDecoration(labelText: field.label),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (v) => isHeader ? setHeaderValue(field.key, v) : setBodyValue(field.key, v),
      );
    }

    case CartillaFieldType.intNumber:
      final v = isHeader ? getHeaderValue(field.key) : getBodyValue(field.key);
      return TextFormField(
        initialValue: v?.toString(),
        decoration: InputDecoration(labelText: field.label),
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
        onChanged: (d) => setBodyValue(field.key, d.round()),
      );

    case CartillaFieldType.longText:
      final txt = (getBodyValue(field.key) as String? ?? '');
      return TextFormField(
        initialValue: txt,
        maxLines: 4,
        decoration: InputDecoration(labelText: field.label),
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
