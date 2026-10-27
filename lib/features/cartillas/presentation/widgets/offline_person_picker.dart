import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../master/presentation/master_providers.dart';

/// Large local catalogs must not create one menu widget per person.
class OfflinePersonPicker extends ConsumerWidget {
  const OfflinePersonPicker({super.key, required this.label, required this.value,
    required this.enabled, required this.onChanged, this.supervisor = false});
  final bool supervisor;
  final String label;
  final String? value;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = supervisor
        ? ref.watch(personasSupActivasStreamProvider)
        : ref.watch(personasActivasByTipoCodigoProvider('OPE'));
    return people.when(
      loading: () => InputDecorator(decoration: InputDecoration(labelText: label),
          child: const Text('Cargando personas…')),
      error: (_, _) => InputDecorator(decoration: InputDecoration(labelText: label),
          child: const Text('No se pudo cargar el catálogo local')),
      data: (rows) {
        dynamic selected;
        for (final row in rows) {
          if ('${row.id}' == value) { selected = row; break; }
        }
        return InkWell(
          onTap: !enabled ? null : () async {
            final controller = TextEditingController();
            var results = rows.take(50).toList();
            final result = await showDialog<String>(context: context,
              builder: (dialogContext) => StatefulBuilder(builder: (context, update) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20,
                    fontWeight: FontWeight.w600),
                  contentTextStyle: const TextStyle(color: Colors.black87, fontSize: 14),
                  title: Text(label),
                  content: SizedBox(width: 480, height: 400, child: Column(children: [
                    TextField(controller: controller, autofocus: true,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      cursorColor: Colors.blue.shade800,
                      decoration: const InputDecoration(labelText: 'Nombre o DNI',
                        labelStyle: TextStyle(color: Colors.black87),
                        prefixIcon: Icon(Icons.search)),
                      onChanged: (text) {
                        final q = text.trim().toLowerCase();
                        update(() => results = rows.where((p) =>
                          '${p.nombreCompleto} ${p.dni}'.toLowerCase().contains(q))
                          .take(50).toList());
                      }),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Se muestran hasta 50 coincidencias. Escriba para filtrar.')),
                    Expanded(child: results.isEmpty
                      ? const Center(child: Text('Sin coincidencias'))
                      : ListView.builder(itemCount: results.length,
                        itemBuilder: (_, index) {
                          final p = results[index];
                          return ListTile(title: Text('${p.nombreCompleto}',
                              style: const TextStyle(color: Colors.black, fontSize: 16,
                                fontWeight: FontWeight.w600)),
                            subtitle: Text('DNI: ${p.dni ?? ""}',
                              style: const TextStyle(color: Colors.black87, fontSize: 14)),
                            onTap: () => Navigator.pop(dialogContext, '${p.id}'));
                        })),
                  ])),
                  actions: [TextButton(onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'))],
                );
              }));
            // Disposal after the dialog route's reverse animation completes.
            Future.delayed(const Duration(seconds: 1), controller.dispose);
            if (result != null) onChanged(result);
          },
          child: InputDecorator(decoration: InputDecoration(labelText: label,
            suffixIcon: const Icon(Icons.search)),
            child: Text(selected == null
              ? (value == null ? 'Buscar o seleccionar' : 'Persona seleccionada: $value')
              : '${selected.nombreCompleto}')),
        );
      },
    );
  }
}
