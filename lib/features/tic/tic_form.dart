import 'tic_surface.dart';
import 'tic_scan.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../cartillas/application/photo_service.dart';
import 'tic_repository.dart';
import 'tic_pages.dart';
import 'tic_choice_field.dart';

class TicFormPage extends ConsumerStatefulWidget {
  const TicFormPage({
    super.key,
    required this.operation,
    this.target = '',
    this.initialValues = const {},
  });
  final Map<String, dynamic> initialValues;
  final String operation;
  final String target;
  @override
  ConsumerState<TicFormPage> createState() => _TicFormPageState();
}

class _TicFormPageState extends ConsumerState<TicFormPage>
    with WidgetsBindingObserver {
  Map<String, dynamic>? schema;
  Map<String, dynamic> values = {}, photos = {}, errors = {};
  final resourceVariants = <String, Map<String, dynamic>>{};
  bool resourceLoading = false;
  final controllers = <String, TextEditingController>{};
  String operationId = ticId(), revision = '', message = '';
  bool loading = true, busy = false, confirmed = false;
  Timer? timer;
  Future<void> pendingSave = Future.value();
  late TicRepository repo;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    repo = ref.read(ticRepositoryProvider);
    load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      timer?.cancel();
      autoSave();
    }
  }

  void autoSave() {
    save().catchError((Object _) {
      if (mounted) {
        setState(
          () => message =
              'No se pudo guardar el avance. Usa Guardar borrador antes de salir.',
        );
      }
    });
  }

  Future<void> load() async {
    try {
      final draft = await repo.draft(widget.operation, widget.target);
      if (draft != null) {
        schema = Map<String, dynamic>.from(draft['schema'] as Map);
        values = Map<String, dynamic>.from(draft['values'] as Map);
        photos = Map<String, dynamic>.from(draft['photos'] as Map? ?? {});
        for (final entry in (draft['resourceVariants'] as Map? ?? {}).entries) {
          resourceVariants['${entry.key}'] = Map<String, dynamic>.from(
            entry.value as Map,
          );
        }
        operationId = '${draft['operationId']}';
        revision = '${draft['revision']}';
        message = 'Borrador recuperado. Revisa los datos antes de confirmar.';
        try {
          final latest = await repo.schema(
            widget.operation,
            widget.target,
            type: widget.operation == 'recurso_nuevo' ? str('tipo') : null,
          );
          schema = latest;
          if (widget.operation == 'componentes' &&
              !values.containsKey('alcance')) {
            values['alcance'] = 'completo';
          }
          for (final raw in latest['fields'] as List) {
            final field = Map<String, dynamic>.from(raw as Map);
            values.putIfAbsent('${field['name']}', () => field['value']);
          }
        } catch (_) {
          message =
              'Borrador recuperado con las listas guardadas. Puedes continuar sin conexión.';
        }
      } else {
        schema = await repo.schema(widget.operation, widget.target);
        revision = '${schema!['revision'] ?? ''}';
        for (final raw in schema!['fields'] as List) {
          final f = Map<String, dynamic>.from(raw as Map);
          values['${f['name']}'] = f['value'];
        }
        final c = Map<String, dynamic>.from(
          schema!['components'] as Map? ?? {},
        );
        for (final item in {
          'ram': 'ram_capacidad',
          'ram_tipos': 'ram_tipo',
          'ram_velocidades': 'ram_velocidad',
          'ram_series': 'ram_serie',
          'discos': 'disco_capacidad',
          'tipos': 'disco_tipo_item',
          'disco_interfaces': 'disco_interfaz',
          'disco_series': 'disco_serie',
        }.entries) {
          values[item.value] = List<dynamic>.from(c[item.key] as List? ?? []);
        }
        values.addAll(widget.initialValues);
        if (widget.operation == 'entrega') values['origen_persona'] = 'TIC';
        if (widget.operation == 'recurso_movimiento') {
          values['accion'] = 'asignar';
        }
      }
    } catch (e) {
      message = ticError(e);
    }
    if (mounted) setState(() => loading = false);
  }

  int resourceRequest = 0;
  Future<void> refreshResource(String type) async {
    setState(() => resourceLoading = true);
    final request = ++resourceRequest;
    try {
      final latest = await repo.schema(
        widget.operation,
        widget.target,
        type: type,
      );
      if (!mounted || request != resourceRequest || str('tipo') != type) return;
      setState(() {
        schema = latest;
        for (final raw in latest['fields'] as List) {
          final field = Map<String, dynamic>.from(raw as Map);
          values.putIfAbsent('${field['name']}', () => field['value']);
        }
      });
    } catch (e) {
      if (mounted && request == resourceRequest) {
        setState(() => message = ticError(e));
      }
    } finally {
      if (mounted && request == resourceRequest) {
        setState(() => resourceLoading = false);
      }
    }
  }

  Map<String, dynamic> snapshot() => {
    'schema': schema,
    'values': Map<String, dynamic>.from(values),
    'photos': Map<String, dynamic>.from(photos),
    'resourceVariants': resourceVariants,
    'operationId': operationId,
    'revision': revision,
  };
  void changed() {
    if (confirmed) return;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 450), () {
      autoSave();
    });
  }

  Future<void> save() {
    if (schema == null || confirmed) return Future.value();
    final raw = jsonDecode(jsonEncode(snapshot())) as Map<String, dynamic>;
    pendingSave = pendingSave
        .catchError((Object _) {})
        .then((_) => repo.saveDraft(widget.operation, widget.target, raw));
    return pendingSave;
  }

  Future<void> manualSave() async {
    timer?.cancel();
    try {
      await save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Borrador guardado en este equipo. Aún no modifica el inventario.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => message = 'No se pudo guardar el borrador en el equipo.',
        );
      }
    }
  }

  String str(String name) => '${values[name] ?? ''}';
  TextEditingController control(String name) => controllers.putIfAbsent(
    name,
    () => TextEditingController(text: str(name)),
  );
  Future<void> submit() async {
    if (resourceLoading) {
      setState(
        () =>
            message = 'Espera a que terminen de cargar los campos del recurso.',
      );
      return;
    }
    if (busy) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => TicDialog(
        icon: const Icon(
          Icons.verified_user_outlined,
          color: Color(0xff168375),
        ),
        title: const Text('Confirmar en DonTec'),
        content: const Text(
          'Se comprobarán permisos, disponibilidad y cambios de la ficha. Confirma únicamente después de revisar los datos. Guardar borrador no realiza este movimiento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Revisar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() {
      busy = true;
      errors = {};
      message = '';
    });
    timer?.cancel();
    try {
      await save();
      final receipt = await repo.confirm(
        widget.operation,
        widget.target,
        snapshot(),
      );
      if (receipt['ok'] != true) {
        throw FormatException(
          '${receipt['error'] ?? 'La operación no fue confirmada.'}',
        );
      }
      confirmed = true;
      await pendingSave;
      await repo.clearDraft(widget.operation, widget.target);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => TicDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Color(0xff168375),
            size: 42,
          ),
          title: const Text('Registro confirmado'),
          content: Text(
            (receipt['messages'] as List? ??
                    ['El movimiento quedó registrado.'])
                .join('\n'),
          ),
          actions: [
            if ('${receipt['pdf'] ?? ''}'.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Compartir PDF'),
                onPressed: () async {
                  try {
                    await repo.sharePdf(
                      '${receipt['pdf']}',
                      '${receipt['title']}',
                    );
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(
                        ctx,
                      ).showSnackBar(SnackBar(content: Text(ticError(e))));
                    }
                  }
                },
              ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Listo'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        errors = Map<String, dynamic>.from(
          (e.response!.data as Map)['fields'] as Map? ?? {},
        );
      }
      if (mounted) setState(() => message = ticError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> discardDraft() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => TicDialog(
        title: const Text('¿Descartar el borrador?'),
        content: const Text(
          'Se elimina el avance de este celular. No se elimina el equipo ni se modifica el inventario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Conservar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    timer?.cancel();
    confirmed = true; // Evita recrear el borrador en dispose/PopScope.
    try {
      await pendingSave.catchError((Object _) {});
      await repo.clearDraft(widget.operation, widget.target);
      if (mounted) {
        ref.invalidate(ticDraftsProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      confirmed = false;
      if (mounted) setState(() => message = ticError(e));
    }
  }

  Future<void> refreshRevision() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => TicDialog(
        title: const Text('Revisar ficha actual'),
        content: const Text(
          'Conservarás lo digitado y cargarás la versión actual del servidor. Compara la ficha del equipo antes de confirmar; pudo cambiar el responsable o el estado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cargar ficha actual'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    try {
      // Si una respuesta se perdió, recuperar primero el acuse, sin crear otra operación.
      try {
        final receipt = await repo.get('estado/$operationId');
        if (receipt['annulled'] == true) {
          if (mounted) {
            setState(
              () => message =
                  'Esta operación fue anulada. Revisa su historial e inicia un formulario nuevo si necesitas otra operación.',
            );
          }
          return;
        }
        if (mounted) {
          setState(
            () => message =
                'Este movimiento ya está confirmado. Consúltalo en Mis documentos.',
          );
        }
        if (receipt['ok'] == true) return;
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
      }
      final current = await repo.schema(
        widget.operation,
        widget.target,
        type: widget.operation == 'recurso_nuevo' ? str('tipo') : null,
      );
      revision = '${current['revision'] ?? ''}';
      schema = current;
      for (final raw in current['fields'] as List) {
        final field = Map<String, dynamic>.from(raw as Map);
        values.putIfAbsent('${field['name']}', () => field['value']);
      }
      if (widget.operation.endsWith('_corregir')) {
        for (final field in current['fields'] as List) {
          final name = '${field['name']}';
          if (name == 'paso' || name == 'movimiento') {
            values[name] = field['value'];
            if (controllers.containsKey(name)) {
              controllers[name]!.text = '${field['value'] ?? ''}';
            }
          }
        }
        values['confirmar'] = false;
      }
      if (mounted) {
        setState(
          () => message =
              'Versión actual cargada. Revisa los datos del equipo antes de confirmar.',
        );
      }
      await save();
    } catch (e) {
      if (mounted) setState(() => message = ticError(e));
    }
  }

  bool visible(String name) {
    if (['origen_persona', 'trabajador', 'documento', 'area'].contains(name) &&
        widget.operation == 'entrega') {
      return false;
    }
    if (name == 'posicion') {
      return ['reemplazar', 'retirar'].contains(str('operacion')) &&
          str('componente') != 'procesador';
    }
    if ([
          'capacidad_gb',
          'ram_tipo',
          'ram_velocidad',
          'tecnologia',
          'disco_interfaz',
          'componente_serie',
          'procesador_nuevo',
          'operacion',
          'componente',
          'destino_retirados',
        ].contains(name) &&
        widget.operation == 'informe_nuevo') {
      if (str('tipo') != 'mejora') return false;
      final c = str('componente');
      if (name == 'componente') return true;
      if (c.isEmpty) return false;
      if (name == 'operacion') return true;
      if (name == 'destino_retirados') {
        return ['reemplazar', 'retirar'].contains(str('operacion'));
      }
      if (name == 'procesador_nuevo') return c == 'procesador';
      if (c == 'procesador' || str('operacion') == 'retirar') return false;
      if (['ram_tipo', 'ram_velocidad'].contains(name)) return c == 'ram';
      if (['tecnologia', 'disco_interfaz'].contains(name)) return c == 'disco';
    }
    if (widget.operation == 'componentes') {
      final scope = str('alcance').isEmpty ? 'completo' : str('alcance');
      if (name == 'procesador') return scope == 'completo';
      if (name == 'ram_cantidad') return scope != 'disco';
      if (name == 'disco_cantidad') return scope != 'ram';
    }
    if (widget.operation == 'equipo_nuevo') {
      final computer = ['pc', 'laptop', 'servidor'].contains(str('tipo'));
      if (['procesador', 'ram_cantidad', 'disco_cantidad'].contains(name)) {
        return computer;
      }
      if (['imei', 'numero_telefonico'].contains(name)) {
        return str('tipo') == 'celular';
      }
    }
    return true;
  }

  Future<void> photo(String name) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => TicSafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar imagen'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final slot = name.endsWith('_2') ? 2 : 1;
      final pic = await PhotoService().captureToSlot(
        localId: 0,
        slot: slot,
        userId: repo.userId,
        storageScope: operationId,
        source: source,
        maxImageDimension: 1600,
      );
      if (pic == null) return;
      final path = pic.localPath;
      if (mounted) setState(() => photos[name] = path);
      changed();
    } catch (_) {
      if (mounted) {
        setState(
          () => message =
              'No se pudo capturar la imagen. Revisa el permiso de cámara.',
        );
      }
    }
  }

  Widget input(Map<String, dynamic> f) {
    final name = '${f['name']}',
        label = '${f['label']}${f['required'] == true ? ' *' : ''}';
    final type = '${f['type']}';
    final allowedTypes = '${f['types'] ?? ''}'.split(',');
    if ((allowedTypes.first.isNotEmpty &&
            !allowedTypes.contains(str('tipo'))) ||
        !visible(name) ||
        type == 'oculto') {
      return const SizedBox.shrink();
    }
    if (resourceLoading && name.startsWith('caracteristica_')) {
      return const SizedBox.shrink();
    }
    final error = errors[name] is List
        ? (errors[name] as List).join('\n')
        : null;
    Widget field;
    if (type == 'booleano') {
      field = CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: values[name] == true || values[name] == 'on',
        title: Text(label),
        subtitle: error == null
            ? null
            : Text(error, style: const TextStyle(color: Colors.red)),
        onChanged: busy
            ? null
            : (v) {
                setState(() => values[name] = v);
                changed();
              },
      );
    } else if (type == 'persona') {
      field = OutlinedButton.icon(
        icon: const Icon(Icons.person_search),
        label: Text(
          str('persona_nombre').isEmpty
              ? 'Buscar trabajador *'
              : str('persona_nombre'),
        ),
        onPressed: busy
            ? null
            : () async {
                final person = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TicListPage(
                      resource: 'trabajadores',
                      title: 'Seleccionar trabajador',
                      pick: true,
                    ),
                  ),
                );
                if (person != null) {
                  setState(() {
                    values['persona_id'] = person['id'];
                    values['persona_nombre'] = person['title'];
                    values['trabajador'] = person['title'];
                    values['documento'] = person['dni'];
                    values['area'] = person['area'];
                  });
                  changed();
                }
              },
      );
    } else if (type == 'firma') {
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label),
          if (str(name).startsWith('data:image'))
            Image.memory(base64Decode(str(name).split(',').last), height: 100),
          OutlinedButton.icon(
            icon: const Icon(Icons.draw),
            label: Text(
              str(name).isEmpty ? 'Firmar recepción' : 'Volver a firmar',
            ),
            onPressed: busy
                ? null
                : () async {
                    final signature = await showDialog<String>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const TicSignatureDialog(),
                    );
                    if (signature != null) {
                      setState(() => values[name] = signature);
                      changed();
                    }
                  },
          ),
        ],
      );
    } else if (type == 'foto') {
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label),
          if (photos[name] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File('${photos[name]}'),
                height: 130,
                fit: BoxFit.contain,
              ),
            ),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Agregar foto'),
                onPressed: busy ? null : () => photo(name),
              ),
              if (photos[name] != null)
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Quitar'),
                  onPressed: busy
                      ? null
                      : () {
                          setState(() => photos.remove(name));
                          changed();
                        },
                ),
            ],
          ),
        ],
      );
    } else if (type == 'lista' || type == 'catalogo') {
      final editable = type == 'catalogo';
      var options = (f[editable ? 'choicesCatalogo' : 'choices'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final entries = f['catalogEntries'] as List? ?? [];
      if (entries.isNotEmpty) {
        String key(String text) =>
            text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        final brand =
            {'samsumg': 'samsung', 'xiomi': 'xiaomi'}[key(
              str('${f['brandField'] ?? 'marca'}'),
            )] ??
            key(str('${f['brandField'] ?? 'marca'}'));
        final contextKey = '${key(str('tipo'))}:$brand';
        options = entries
            .where((e) => e['contexto'] == contextKey)
            .map(
              (e) => <String, dynamic>{
                'value': e['valor'],
                'label': e['valor'],
              },
            )
            .toList();
      }
      final missingContext =
          entries.isNotEmpty &&
          (str('tipo').isEmpty || str('${f['brandField'] ?? 'marca'}').isEmpty);
      field = TicChoiceField(
        key: ValueKey(name),
        label: label,
        value: str(name),
        options: options,
        allowNew: editable,
        enabled:
            !busy &&
            !missingContext &&
            f['disabled'] != true &&
            f['readonly'] != true,
        errorText: error,
        maxLength: f['maxLength'] as int?,
        onChanged: (value) {
          final previous = str(name);
          setState(() {
            values[name] = value;
            if (previous != value) {
              if (name == 'tipo' && widget.operation == 'recurso_nuevo') {
                resourceVariants[previous] = Map.fromEntries(
                  values.entries.where(
                    (e) => e.key.startsWith('caracteristica_'),
                  ),
                );
                values.removeWhere(
                  (key, _) => key.startsWith('caracteristica_'),
                );
                values.addAll(resourceVariants[value] ?? {});
                for (final entry in controllers.entries.where(
                  (e) => e.key.startsWith('caracteristica_'),
                )) {
                  entry.value.text = str(entry.key);
                }
              }
              for (final raw in schema!['fields'] as List) {
                final dependent = Map<String, dynamic>.from(raw as Map);
                final id = '${dependent['name']}';
                final model =
                    id == 'modelo' ||
                    (dependent['catalogEntries'] as List? ?? []).isNotEmpty;
                if (model &&
                    (name == 'tipo' ||
                        name == '${dependent['brandField'] ?? 'marca'}')) {
                  values[id] = '';
                  controllers[id]?.clear();
                }
              }
            }
            if (name == 'tipo' &&
                str('tipo') != 'mejora' &&
                widget.operation == 'informe_nuevo') {
              values['componente'] = '';
            }
          });
          changed();
          if (name == 'tipo' &&
              value.isNotEmpty &&
              widget.operation == 'recurso_nuevo') {
            refreshResource(value);
          }
        },
      );
    } else {
      final suggestionMap = Map<String, dynamic>.from(
        schema!['suggestions'] as Map? ?? {},
      );
      final options = (suggestionMap[name] as List? ?? [])
          .map((e) => '$e')
          .toList();
      field = TextField(
        controller: control(name),
        readOnly:
            type == 'fecha' || f['disabled'] == true || f['readonly'] == true,
        enabled: !busy,
        maxLines: type == 'multilinea' ? 3 : 1,
        maxLength: f['maxLength'] as int?,
        keyboardType: type == 'numero'
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          counterText: '',
          border: const OutlineInputBorder(),
          suffixIcon: type == 'fecha' ? const Icon(Icons.calendar_today) : null,
        ),
        onTap: type == 'fecha'
            ? () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(str(name)) ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  values[name] = date.toIso8601String().split('T').first;
                  control(name).text = str(name);
                  changed();
                }
              }
            : null,
        onChanged: (v) {
          values[name] = v;
          changed();
          if (options.isNotEmpty ||
              ['ram_cantidad', 'disco_cantidad'].contains(name)) {
            setState(() {});
          }
        },
      );
      if (options.isNotEmpty) {
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            field,
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: options
                    .where(
                      (s) => s.toLowerCase().contains(str(name).toLowerCase()),
                    )
                    .take(8)
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(s),
                          onPressed: busy
                              ? null
                              : () {
                                  values[name] = s;
                                  control(name).text = s;
                                  changed();
                                },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          field,
          if ('${f['help'] ?? ''}'.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                '${f['help']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget components(String kind) {
    final ram = kind == 'ram';
    final n = (int.tryParse(str('${kind}_cantidad')) ?? 0).clamp(
      0,
      ram ? 64 : 16,
    );
    final names = ram
        ? ['ram_capacidad', 'ram_tipo', 'ram_velocidad', 'ram_serie']
        : [
            'disco_capacidad',
            'disco_tipo_item',
            'disco_interfaz',
            'disco_serie',
          ];
    final labels = ram
        ? [
            'Capacidad (GB o TB)',
            'Tipo / formato',
            'Frecuencia (MHz / MT/s)',
            'Serie (opcional)',
          ]
        : ['Capacidad (GB o TB)', 'Tecnología', 'Interfaz', 'Serie (opcional)'];
    Future<void> removePiece(int index) async {
      final yes = await showDialog<bool>(
        context: context,
        builder: (ctx) => TicDialog(
          title: Text('¿Quitar ${ram ? 'memoria RAM' : 'disco'} ${index + 1}?'),
          content: const Text(
            'Solo se quita esta pieza del formulario. El inventario cambia al confirmar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Conservar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Quitar'),
            ),
          ],
        ),
      );
      if (yes != true || !mounted) return;
      setState(() {
        for (final name in names) {
          final pieces = List<dynamic>.from(values[name] as List? ?? []);
          if (index < pieces.length) pieces.removeAt(index);
          values[name] = pieces;
          for (var i = 0; i < n; i++) {
            controllers['$name:$i']?.text = i < pieces.length
                ? '${pieces[i]}'
                : '';
          }
        }
        values['${kind}_cantidad'] = n - 1;
        control('${kind}_cantidad').text = '${n - 1}';
      });
      changed();
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(ram ? 'Agregar memoria RAM' : 'Agregar disco'),
            onPressed: busy || n >= (ram ? 64 : 16)
                ? null
                : () {
                    setState(() {
                      values['${kind}_cantidad'] = n + 1;
                      control('${kind}_cantidad').text = '${n + 1}';
                    });
                    changed();
                  },
          ),
        ),
        ...List.generate(
          n,
          (i) => Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${ram ? 'Memoria RAM' : 'Disco'} ${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        tooltip:
                            'Quitar ${ram ? 'memoria RAM' : 'disco'} ${i + 1}',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: busy ? null : () => removePiece(i),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (var j = 0; j < names.length; j++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: componentInput(names[j], labels[j], i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget componentInput(String name, String label, int i) {
    final initial = List<dynamic>.from(values[name] as List? ?? []);
    while (initial.length <= i) {
      initial.add('');
    }
    values[name] = initial;
    void write(String value) {
      final current = List<dynamic>.from(values[name] as List? ?? []);
      while (current.length <= i) {
        current.add('');
      }
      current[i] = value;
      values[name] = current;
      changed();
    }

    if (name == 'disco_tipo_item') {
      return DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        initialValue: ['ssd', 'hdd'].contains('${initial[i]}')
            ? '${initial[i]}'
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'ssd', child: Text('SSD')),
          DropdownMenuItem(value: 'hdd', child: Text('HDD')),
        ],
        onChanged: busy ? null : (v) => write(v ?? ''),
      );
    }
    final suggestions =
        (schema!['suggestions'] as Map? ?? {})[name] as List? ?? [];
    if (!name.endsWith('_serie')) {
      return TicChoiceField(
        key: ValueKey('$name:$i'),
        label: label,
        value: '${initial[i]}',
        options: suggestions
            .map((v) => <String, dynamic>{'value': '$v', 'label': '$v'})
            .toList(),
        allowNew: true,
        enabled: !busy,
        maxLength: name.contains('capacidad') ? 30 : 100,
        onChanged: (v) {
          write(v);
          setState(() {});
        },
      );
    }
    final key = '$name:$i';
    controllers.putIfAbsent(
      key,
      () => TextEditingController(text: '${initial[i]}'),
    );
    return TextField(
      controller: controllers[key],
      enabled: !busy,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: write,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !busy,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !confirmed) {
          timer?.cancel();
          autoSave();
        }
      },
      child: TicScaffold(
        appBar: AppBar(
          title: Text('${schema?['title'] ?? 'Cartilla TIC'}'),
          actions: [
            IconButton(
              tooltip: 'Descartar borrador',
              onPressed: busy || loading ? null : discardDraft,
              icon: const Icon(Icons.delete_outline),
            ),
            IconButton(
              tooltip: 'Revisar versión actual',
              onPressed: busy ? null : refreshRevision,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : schema == null
            ? Center(child: Text(message))
            : AbsorbPointer(
                absorbing: busy,
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Card(
                      color: const Color(0xffe8f3ef),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          widget.operation == 'entrega'
                              ? 'La firma corresponde al trabajador que recibe. El inventario se actualiza al confirmar con conexión.'
                              : 'El avance queda en este celular. Guardar borrador no modifica el inventario ni confirma el movimiento.',
                        ),
                      ),
                    ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          message,
                          style: const TextStyle(color: Color(0xff9b472b)),
                        ),
                      ),
                    if (errors['__all__'] != null)
                      Text(
                        '${errors['__all__']}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 12),
                    ...(schema!['fields'] as List).map(
                      (f) => input(Map<String, dynamic>.from(f as Map)),
                    ),
                    if (widget.operation == 'componentes' ||
                        (widget.operation == 'equipo_nuevo' &&
                            [
                              'pc',
                              'laptop',
                              'servidor',
                            ].contains(str('tipo')))) ...[
                      if (widget.operation != 'componentes' ||
                          str('alcance') != 'disco')
                        components('ram'),
                      if (widget.operation != 'componentes' ||
                          str('alcance') != 'ram')
                        components('disco'),
                    ],
                    if (widget.operation.endsWith('_corregir'))
                      Card(
                        color: const Color(0xfffff2df),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            '${(schema!['correction'] as Map?)?['accion'] ?? 'Anular la última operación'}\n'
                            '${(schema!['correction'] as Map?)?['bloqueo'] ?? ''}\n'
                            'Si tiene movimientos, se anulan desde el último hacia el primero. Se conserva el respaldo.',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    if (resourceLoading) const LinearProgressIndicator(),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: manualSave,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Guardar borrador'),
                        ),
                        FilledButton.icon(
                          onPressed:
                              resourceLoading ||
                                  '${(schema!['correction'] as Map?)?['bloqueo'] ?? ''}'
                                      .isNotEmpty
                              ? null
                              : submit,
                          icon: busy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.cloud_done_outlined),
                          label: Text(
                            widget.operation.endsWith('_corregir')
                                ? 'Confirmar anulación'
                                : 'Confirmar en DonTec',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
      ),
    );
  }
}

class TicChoiceSearch extends SearchDelegate<Map<String, dynamic>?> {
  TicChoiceSearch(this.options, {this.allowNew = false, this.maxLength});
  final List<Map<String, dynamic>> options;
  final bool allowNew;
  final int? maxLength;
  String searchKey(String value) {
    var text = value.toLowerCase();
    const from = 'áéíóúüñ', to = 'aeiouun';
    for (var i = 0; i < from.length; i++) {
      text = text.replaceAll(from[i], to[i]);
    }
    return text;
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      tooltip: 'Leer QR o código de barras',
      icon: const Icon(Icons.qr_code_scanner),
      onPressed: () async {
        final code = await scanTicCode(context);
        if (code != null) query = code;
      },
    ),
    IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );
  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
  @override
  Widget buildSuggestions(BuildContext context) {
    final list = options
        .where(
          (o) => searchKey(query)
              .split(RegExp(r'\s+'))
              .every(
                (word) =>
                    searchKey('${o['label']} ${o['value']}').contains(word),
              ),
        )
        .toList();
    final value = query.trim();
    final add =
        allowNew &&
        value.isNotEmpty &&
        (maxLength == null || value.length <= maxLength!) &&
        !options.any(
          (o) => '${o['value']}'.toLowerCase() == value.toLowerCase(),
        );
    return TicSurface(
      child: ListView(
        children: [
          if (allowNew && value.isEmpty)
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Dejar sin seleccionar'),
              onTap: () => close(context, {'value': '', 'label': ''}),
            ),
          if (add)
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text('Usar: $value'),
              subtitle: const Text(
                'Se incorporará a las opciones al guardar correctamente.',
              ),
              onTap: () => close(context, {'value': value, 'label': value}),
            ),
          ...list
              .take(100)
              .map(
                (o) => ListTile(
                  title: Text('${o['label']}'),
                  onTap: () => close(context, o),
                ),
              ),
          if (list.length > 100)
            const ListTile(title: Text('Escribe para precisar la búsqueda.')),
        ],
      ),
    );
  }
}

class TicSignatureDialog extends StatefulWidget {
  const TicSignatureDialog({super.key});
  @override
  State<TicSignatureDialog> createState() => _TicSignatureDialogState();
}

class _TicSignatureDialogState extends State<TicSignatureDialog> {
  final points = <Offset?>[];
  @override
  Widget build(BuildContext context) => TicDialog(
    title: const Text('Firma de quien recibe'),
    content: SizedBox(
      width: 700,
      height: 230,
      child: LayoutBuilder(
        builder: (_, box) => GestureDetector(
          onPanUpdate: (d) => setState(
            () => points.add(
              Offset(
                (d.localPosition.dx / box.maxWidth).clamp(0, 1),
                (d.localPosition.dy / box.maxHeight).clamp(0, 1),
              ),
            ),
          ),
          onPanEnd: (_) => points.add(null),
          child: CustomPaint(
            size: Size(box.maxWidth, box.maxHeight),
            painter: _SignaturePainter(points),
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      TextButton(
        onPressed: () => setState(points.clear),
        child: const Text('Limpiar'),
      ),
      FilledButton(
        onPressed: points.whereType<Offset>().length < 5
            ? null
            : () async {
                final recorder = ui.PictureRecorder();
                final canvas = Canvas(recorder);
                _SignaturePainter(points).paint(canvas, const Size(700, 240));
                final image = await recorder.endRecording().toImage(700, 240);
                final bytes = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                image.dispose();
                if (context.mounted && bytes != null) {
                  Navigator.pop(
                    context,
                    'data:image/png;base64,${base64Encode(bytes.buffer.asUint8List())}',
                  );
                }
              },
        child: const Text('Usar firma'),
      ),
    ],
  );
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.points);
  final List<Offset?> points;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final pen = Paint()
      ..color = const Color(0xff163953)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < points.length; i++) {
      if (points[i - 1] != null && points[i] != null) {
        canvas.drawLine(
          Offset(
            points[i - 1]!.dx * size.width,
            points[i - 1]!.dy * size.height,
          ),
          Offset(points[i]!.dx * size.width, points[i]!.dy * size.height),
          pen,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
