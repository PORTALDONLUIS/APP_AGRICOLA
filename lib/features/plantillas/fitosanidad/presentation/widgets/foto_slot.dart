import 'package:flutter/material.dart';
import '../../domain/cartilla_fito_payload.dart';

class FotoSlot extends StatelessWidget {
  final List<CartillaFitoFotoRef> fotos;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const FotoSlot({
    super.key,
    required this.fotos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Fotos', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (fotos.isEmpty)
          const Text('Sin fotos todavía.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < fotos.length; i++)
                Chip(
                  label: Text('Slot ${fotos[i].slot} (att ${fotos[i].attachmentLocalId})'),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => onRemove(i),
                ),
            ],
          ),
      ],
    );
  }
}
