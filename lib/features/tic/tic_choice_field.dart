import 'dart:math' as math;
import 'package:flutter/material.dart';

String ticChoiceKey(String value) {
  var text = value.toLowerCase();
  const from = 'áéíóúüñ', to = 'aeiouun';
  for (var i = 0; i < from.length; i++) {
    text = text.replaceAll(from[i], to[i]);
  }
  return text.trim();
}

class TicChoiceOption {
  const TicChoiceOption(this.value, this.label, {this.selectable = true});
  final String value, label;
  final bool selectable;
}

/// Lista desplegable local: sin navegar a otra pantalla ni consultar por tecla.
class TicChoiceField extends StatefulWidget {
  const TicChoiceField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.allowNew = false,
    this.enabled = true,
    this.errorText,
    this.maxLength,
  });
  final String label, value;
  final List<Map<String, dynamic>> options;
  final ValueChanged<String> onChanged;
  final bool allowNew, enabled;
  final String? errorText;
  final int? maxLength;
  @override
  State<TicChoiceField> createState() => _TicChoiceFieldState();
}

class _TicChoiceFieldState extends State<TicChoiceField> {
  late final TextEditingController controller;
  final focus = FocusNode();
  late String value;
  bool searching = false;

  String display(String selected) {
    if (selected.isEmpty) return '';
    for (final option in widget.options) {
      if ('${option['value']}' == selected) return '${option['label']}';
    }
    return selected;
  }

  @override
  void initState() {
    super.initState();
    value = widget.value;
    controller = TextEditingController(text: display(value));
    focus.addListener(onFocus);
  }

  void onFocus() {
    if (!focus.hasFocus) {
      searching = false;
      controller.text = display(value);
      if (mounted) setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant TicChoiceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      value = widget.value;
      if (!focus.hasFocus) controller.text = display(value);
    }
  }

  void write(String next) {
    value = next;
    widget.onChanged(next);
    if (mounted) setState(() {});
  }

  void open() {
    if (!widget.enabled) return;
    searching = true;
    controller.clear();
    focus.requestFocus();
    setState(() {});
  }

  @override
  void dispose() {
    focus.removeListener(onFocus);
    focus.dispose();
    controller.dispose();
    super.dispose();
  }

  OptionsViewOpenDirection direction() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return OptionsViewOpenDirection.down;
    final media = MediaQuery.of(context);
    final top = box.localToGlobal(Offset.zero).dy;
    final below =
        media.size.height - media.viewInsets.bottom - top - box.size.height;
    return below < 200 && top > below
        ? OptionsViewOpenDirection.up
        : OptionsViewOpenDirection.down;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      return RawAutocomplete<TicChoiceOption>(
        textEditingController: controller,
        focusNode: focus,
        optionsViewOpenDirection: direction(),
        displayStringForOption: (option) => option.label,
        optionsBuilder: (editing) {
          if (!widget.enabled) return const Iterable<TicChoiceOption>.empty();
          final query = ticChoiceKey(editing.text);
          final words = query.split(RegExp(r'\s+'));
          final options = widget.options
              .where((o) => '${o['value'] ?? ''}'.isNotEmpty)
              .where(
                (o) => words.every(
                  (word) => ticChoiceKey(
                    '${o['label']} ${o['value']}',
                  ).contains(word),
                ),
              )
              .take(80)
              .map((o) => TicChoiceOption('${o['value']}', '${o['label']}'))
              .toList();
          final typed = editing.text.trim();
          if (widget.allowNew &&
              typed.isNotEmpty &&
              (widget.maxLength == null || typed.length <= widget.maxLength!) &&
              !widget.options.any(
                (o) => ticChoiceKey('${o['value']}') == query,
              )) {
            options.add(TicChoiceOption(typed, 'Usar: $typed'));
          }
          if (options.isEmpty) {
            options.add(
              const TicChoiceOption(
                '',
                'No hay coincidencias',
                selectable: false,
              ),
            );
          }
          return options;
        },
        onSelected: (option) {
          if (!option.selectable) return;
          write(option.value);
          controller.text = display(option.value);
          focus.unfocus();
        },
        fieldViewBuilder: (context, text, node, submit) => TextField(
          controller: text,
          focusNode: node,
          enabled: widget.enabled,
          maxLength: widget.maxLength,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.allowNew
                ? 'Buscar o escribir una opción'
                : 'Seleccionar...',
            errorText: widget.errorText,
            counterText: '',
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value.isNotEmpty || controller.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Quitar selección de ${widget.label}',
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: widget.enabled
                        ? () {
                            write('');
                            open();
                          }
                        : null,
                  ),
                IconButton(
                  tooltip: 'Mostrar opciones de ${widget.label}',
                  icon: const Icon(Icons.expand_more),
                  onPressed: widget.enabled ? open : null,
                ),
              ],
            ),
          ),
          onTap: () {
            if (!searching) open();
          },
          onChanged: (typed) {
            searching = true;
            if (widget.allowNew) {
              write(typed);
            } else {
              setState(() {});
            }
          },
          onSubmitted: (_) {
            if (widget.allowNew) {
              write(controller.text.trim());
              focus.unfocus();
            } else {
              submit();
            }
          },
        ),
        optionsViewBuilder: (context, choose, options) => Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: Material(
              elevation: 8,
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: math.min(
                    280,
                    MediaQuery.sizeOf(context).height * .38,
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final option = options.elementAt(i);
                    return ListTile(
                      dense: true,
                      selected:
                          option.value.isNotEmpty && option.value == value,
                      enabled: option.selectable,
                      title: Text(option.label),
                      onTap: option.selectable ? () => choose(option) : null,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
