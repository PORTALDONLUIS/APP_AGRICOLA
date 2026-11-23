import 'package:flutter/material.dart';

/// El diálogo mantiene sus campos montados durante la animación de cierre.
/// No se liberan controladores desde el Future de showDialog, que termina antes.
Future<Map<String, String>?> showPackingCatalogDialog(
  BuildContext context,
  String tipo, {
  String initialFirst = '',
  String initialSecond = '',
  bool editing = false,
}) {
  var first = initialFirst;
  var second = initialSecond;
  final paired = tipo == 'LUGAR_PRODUCCION';

  return showDialog<Map<String, String>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        editing
            ? 'Editar opción'
            : paired
            ? 'Agregar fundo y código'
            : 'Agregar opción',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            autofocus: true,
            initialValue: initialFirst,
            decoration: InputDecoration(labelText: paired ? 'Fundo' : 'Nombre'),
            textCapitalization: TextCapitalization.words,
            onChanged: (value) => first = value,
          ),
          if (paired) ...[
            const SizedBox(height: 12),
            TextFormField(
              initialValue: initialSecond,
              decoration: const InputDecoration(
                labelText: 'Código de lugar de producción',
              ),
              onChanged: (value) => second = value,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final a = first.trim();
            final b = second.trim();
            if (a.isEmpty || (paired && b.isEmpty)) return;
            Navigator.pop(dialogContext, {'primero': a, 'segundo': b});
          },
          child: Text(editing ? 'Guardar' : 'Agregar'),
        ),
      ],
    ),
  );
}
