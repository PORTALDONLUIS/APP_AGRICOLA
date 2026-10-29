import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tic_repository.dart';
import 'tic_form.dart';

const ticGreen = Color(0xff168375);

class TicListPage extends ConsumerStatefulWidget {
  const TicListPage({
    super.key,
    required this.resource,
    required this.title,
    this.pick = false,
    this.operations = const [],
    this.operation,
    this.extraQuery = const {},
  });
  final String resource, title;
  final bool pick;
  final String? operation;
  final Map<String, dynamic> extraQuery;
  final List<Map<String, dynamic>> operations;
  @override
  ConsumerState<TicListPage> createState() => _TicListPageState();
}

class _TicListPageState extends ConsumerState<TicListPage> {
  List<Map<String, dynamic>> items = [];
  int page = 1, pages = 1, total = 0, generation = 0;
  bool loading = true;
  String query = '', error = '';
  Timer? timer;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    final seq = ++generation;
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final result = await ref
          .read(ticRepositoryProvider)
          .get(widget.resource, {
            ...widget.extraQuery,
            'q': query,
            'page': page,
            if (widget.pick && widget.resource == 'trabajadores')
              'habilitados': '1',
          });
      if (!mounted || seq != generation) return;
      setState(() {
        items = (result['items'] as List)
            .map((o) => Map<String, dynamic>.from(o as Map))
            .toList();
        pages = (result['pages'] as num).toInt();
        total = (result['total'] as num? ?? items.length).toInt();
      });
    } catch (e) {
      if (mounted && seq == generation) setState(() => error = ticError(e));
    } finally {
      if (mounted && seq == generation) setState(() => loading = false);
    }
  }

  Future<void> open(Map<String, dynamic> item) async {
    if (widget.pick) {
      if (widget.resource == 'trabajadores' && item['canReceive'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Completa área, cargo y empresa de este trabajador antes de asignarle.',
            ),
          ),
        );
        return;
      }
      Navigator.pop(context, item);
      return;
    }
    if (widget.operation != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicFormPage(
            operation: widget.operation!,
            target: '${item['id']}',
          ),
        ),
      );
    } else if (widget.resource == 'equipos') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicEquipmentPage(
            id: '${item['id']}',
            operations: widget.operations,
          ),
        ),
      );
    } else if (widget.resource == 'documentos') {
      final receipt = Map<String, dynamic>.from(item['document'] as Map);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('${receipt['title']}'),
          content: Text((receipt['messages'] as List? ?? []).join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
            if ('${receipt['pdf'] ?? ''}'.isNotEmpty)
              FilledButton.icon(
                onPressed: () =>
                    share('${receipt['pdf']}', '${receipt['title']}'),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Compartir PDF'),
              ),
          ],
        ),
      );
    } else {
      final worker = widget.resource == 'trabajadores';
      final ops = widget.operations
          .where((o) => o['target'] == (worker ? 'trabajador' : 'recurso'))
          .toList();
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item['title']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${item['subtitle']}'),
                for (final op in ops)
                  ListTile(
                    leading: const Icon(Icons.edit_note),
                    title: Text('${op['title']}'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicFormPage(
                            operation: '${op['id']}',
                            target: '${item['id']}',
                          ),
                        ),
                      ).then((_) => load());
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(
                    worker
                        ? 'Todo lo asignado · compartir PDF'
                        : 'Ficha e historial · compartir PDF',
                  ),
                  onTap: () => share(
                    '${worker ? 'trabajador' : 'recurso'}/${item['id']}',
                    '${item['title']}',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (mounted) load();
  }

  Future<void> share(String pdf, String title) async {
    try {
      await ref.read(ticRepositoryProvider).sharePdf(pdf, title);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ticError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Column(
      children: [
        if (widget.resource != 'documentos')
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Código, serie, nombre o descripción',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (q) {
                query = q;
                page = 1;
                timer?.cancel();
                timer = Timer(const Duration(milliseconds: 450), load);
              },
            ),
          ),
        if (error.isNotEmpty)
          Padding(padding: const EdgeInsets.all(16), child: Text(error)),
        if (loading) const LinearProgressIndicator(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: load,
            child: items.isEmpty && !loading
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(
                        child: Text('No hay registros para esta búsqueda.'),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: items.length,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemBuilder: (_, i) => Card(
                      child: ListTile(
                        title: Text('${items[i]['title']}'),
                        subtitle: Text('${items[i]['subtitle']}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => open(items[i]),
                      ),
                    ),
                  ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: !loading && page > 1
                      ? () {
                          page--;
                          load();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Página $page de $pages · $total registros'),
                IconButton(
                  onPressed: !loading && page < pages
                      ? () {
                          page++;
                          load();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class TicEquipmentPage extends ConsumerStatefulWidget {
  const TicEquipmentPage({
    super.key,
    required this.id,
    required this.operations,
  });
  final String id;
  final List<Map<String, dynamic>> operations;
  @override
  ConsumerState<TicEquipmentPage> createState() => _TicEquipmentPageState();
}

class _TicEquipmentPageState extends ConsumerState<TicEquipmentPage> {
  Map<String, dynamic>? data;
  String error = '';
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await ref
          .read(ticRepositoryProvider)
          .get('detalle/${widget.id}');
      if (mounted) {
        setState(() {
          data = result;
          error = '';
        });
      }
    } catch (e) {
      if (mounted &&
          data != null &&
          e is DioException &&
          e.response?.statusCode == 404) {
        Navigator.pop(context, true);
        return;
      }
      if (mounted) setState(() => error = ticError(e));
    }
  }

  Future<void> form(String op, String id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicFormPage(operation: op, target: id),
      ),
    );
    if (mounted) load();
  }

  Future<void> share(String reference) async {
    try {
      await ref
          .read(ticRepositoryProvider)
          .sharePdf(reference, '${data?['title'] ?? 'Documento TIC'}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ticError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('${data?['title'] ?? 'Equipo'}'),
      actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh))],
    ),
    body: data == null
        ? Center(
            child: error.isEmpty
                ? const CircularProgressIndicator()
                : Text(error),
          )
        : ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                color: const Color(0xffe8f3ef),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data!['title']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${data!['subtitle']}'),
                      const SizedBox(height: 8),
                      Text('Custodia: ${data!['status']}'),
                      Text(
                        'Responsable: ${'${data!['assignedTo']}'.isEmpty ? 'Sin asignación' : data!['assignedTo']}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => share('equipo/${widget.id}'),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF del equipo'),
                  ),
                  if ('${data!['assignmentId']}'.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => share('acta/${data!['assignmentId']}'),
                      icon: const Icon(Icons.draw),
                      label: const Text('Acta de entrega'),
                    ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Acciones',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              for (final op in widget.operations.where(
                (o) => o['target'] == 'equipo',
              ))
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment_outlined),
                    title: Text('${op['title']}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => form('${op['id']}', widget.id),
                  ),
                ),
              ExpansionTile(
                title: const Text('Ficha del equipo'),
                children: [
                  for (final raw in data!['details'] as List? ?? [])
                    Builder(
                      builder: (_) {
                        final field = raw as Map;
                        return ListTile(
                          title: Text('${field['label']}'),
                          subtitle: Text('${field['value']}'),
                        );
                      },
                    ),
                ],
              ),
              ExpansionTile(
                title: const Text('RAM y almacenamiento'),
                children: [
                  for (final key in ['ram', 'disks']) ...[
                    for (final item in data![key] as List)
                      ListTile(
                        title: Text(
                          '${key == 'ram' ? 'RAM' : 'Disco'} · ${(item as Map)['capacidad_gb']} GB',
                        ),
                        subtitle: Text(
                          '${item['tipo'] ?? ''} ${item['velocidad'] ?? ''} ${item['interfaz'] ?? ''} ${item['serie'] ?? ''}',
                        ),
                      ),
                  ],
                ],
              ),
              ExpansionTile(
                title: const Text('Informes técnicos'),
                initiallyExpanded: true,
                children: [
                  for (final raw in data!['reports'] as List)
                    Builder(
                      builder: (context) {
                        final item = raw as Map;
                        return ListTile(
                          title: Text('${item['title']}'),
                          subtitle: Text(
                            item['closed'] == true
                                ? 'Cerrado'
                                : 'Abierto · requiere atención',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'pdf') {
                                share('informe/${item['id']}');
                              } else {
                                form('informe_cerrar', '${item['id']}');
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'pdf',
                                child: Text('Compartir PDF'),
                              ),
                              if (item['closed'] != true &&
                                  widget.operations.any(
                                    (o) => o['id'] == 'informe_cerrar',
                                  ))
                                const PopupMenuItem(
                                  value: 'close',
                                  child: Text('Diagnóstico y cierre'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              ExpansionTile(
                title: const Text('Historial reciente'),
                children: [
                  for (final raw in data!['history'] as List)
                    Builder(
                      builder: (_) {
                        final m = raw as Map;
                        return ListTile(
                          title: Text('${m['title']}'),
                          subtitle: Text('${m['date']}\n${m['text']}'),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
  );
}

class TicReportsPage extends ConsumerStatefulWidget {
  const TicReportsPage({super.key});
  @override
  ConsumerState<TicReportsPage> createState() => _TicReportsPageState();
}

class _TicReportsPageState extends ConsumerState<TicReportsPage> {
  String type = 'inventario', company = '', q = '', error = '';
  bool busy = false;
  DateTime? from, to;
  Future<void> share() async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await ref
          .read(ticRepositoryProvider)
          .sharePdf(
            'reporte/$type',
            'Reporte TIC · $type',
            query: {
              'q': q,
              'empresa': company,
              if (from != null)
                'desde': from!.toIso8601String().split('T').first,
              if (to != null) 'hasta': to!.toIso8601String().split('T').first,
            },
          );
    } catch (e) {
      if (mounted) setState(() => error = ticError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reportes TIC')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'PDF corporativo con indicadores y gráficas. Máximo 500 filas por reporte; utiliza filtros para mantenerlo claro.',
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          initialValue: type,
          decoration: const InputDecoration(
            labelText: 'Reporte',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'inventario', child: Text('Inventario')),
            DropdownMenuItem(
              value: 'asignaciones',
              child: Text('Asignaciones actuales'),
            ),
            DropdownMenuItem(value: 'historial', child: Text('Historial')),
            DropdownMenuItem(
              value: 'mantenimiento',
              child: Text('Mantenimiento'),
            ),
            DropdownMenuItem(
              value: 'tecnico',
              child: Text('Informes técnicos'),
            ),
          ],
          onChanged: busy ? null : (v) => setState(() => type = v!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          initialValue: company,
          decoration: const InputDecoration(
            labelText: 'Empresa',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: '', child: Text('Todas')),
            DropdownMenuItem(value: 'don-luis', child: Text('Don Luis')),
            DropdownMenuItem(value: 'campo-verde', child: Text('Campo Verde')),
            DropdownMenuItem(value: 'ajs', child: Text('AJS')),
          ],
          onChanged: busy ? null : (v) => setState(() => company = v!),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Código, serie o responsable',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => q = v,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: [
            for (final initial in [true, false])
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  '${initial ? 'Desde' : 'Hasta'}: ${(initial ? from : to)?.toIso8601String().split('T').first ?? 'sin filtro'}',
                ),
                onPressed: busy
                    ? null
                    : () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            if (initial) {
                              from = date;
                            } else {
                              to = date;
                            }
                          });
                        }
                      },
              ),
            TextButton(
              onPressed: () => setState(() {
                from = null;
                to = null;
              }),
              child: const Text('Quitar fechas'),
            ),
          ],
        ),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(error, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: busy ? null : share,
          icon: const Icon(Icons.picture_as_pdf),
          label: Text(busy ? 'Preparando PDF...' : 'Generar y compartir PDF'),
        ),
      ],
    ),
  );
}
