import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericStepperField extends StatefulWidget {
  final String label;
  final double value;
  final double step;
  final double min;
  final double? max;
  final String? suffix;
  final ValueChanged<double> onChanged;
  final bool readOnly;

  const NumericStepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 0.5,
    this.min = 0,
    this.max,
    this.suffix,
    this.readOnly = false,
  });

  @override
  State<NumericStepperField> createState() => _NumericStepperFieldState();
}

class _NumericStepperFieldState extends State<NumericStepperField> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _valueToText(widget.value));
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NumericStepperField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = _valueToText(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      final text = _controller.text.trim();
      if (text == '0' || text == '0.0') {
        _controller.clear();
      } else {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
      return;
    }
    _commitText();
  }

  String _valueToText(double v) {
    if (v.isNaN || v.isInfinite) return '0';
    return v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  void _commitText() {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      _controller.text = _valueToText(widget.value);
      return;
    }
    final parsed = double.tryParse(input.replaceFirst(',', '.'));
    if (parsed == null) {
      _controller.text = _valueToText(widget.value);
      return;
    }
    var clamped = parsed;
    if (clamped < widget.min) clamped = widget.min;
    final maxVal = widget.max;
    if (maxVal != null && clamped > maxVal) clamped = maxVal;
    if (clamped != widget.value) widget.onChanged(clamped);
    _controller.text = _valueToText(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final value = widget.value.isNaN || widget.value.isInfinite
        ? 0.0
        : widget.value;
    final min = widget.min.isNaN || widget.min.isInfinite ? 0.0 : widget.min;
    final max =
        (widget.max != null && (widget.max!.isNaN || widget.max!.isInfinite))
        ? null
        : widget.max;

    final canDec = !widget.readOnly && value > min;
    final canInc =
        widget.readOnly == false && (max == null ? true : value < max);

    Widget circleButton({
      required IconData icon,
      required bool enabled,
      required VoidCallback onTap,
    }) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.4,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled ? onTap : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceContainerHighest,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(
              icon,
              size: 18,
              color: enabled ? cs.onSurfaceVariant : cs.outline,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            '${widget.label}${widget.suffix != null ? " (${widget.suffix})" : ""}',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        circleButton(
          icon: Icons.remove,
          enabled: canDec,
          onTap: () {
            var next = value - widget.step;
            if (next < min) next = min;
            widget.onChanged(next);
            _controller.text = _valueToText(next);
          },
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: widget.readOnly,
            enabled: !widget.readOnly,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                final text = newValue.text.replaceFirst(',', '.');
                final dotCount = '.'.allMatches(text).length;
                if (dotCount > 1) return oldValue;
                if (dotCount == 1) {
                  final parts = text.split('.');
                  if (parts.length == 2 && parts[1].length > 1) return oldValue;
                }
                return TextEditingValue(
                  text: text,
                  selection: newValue.selection,
                );
              }),
            ],
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            onTap: () {
              final text = _controller.text.trim();
              if (text == '0' || text == '0.0') {
                _controller.clear();
                return;
              }
              _controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controller.text.length,
              );
            },
            onFieldSubmitted: (_) => _commitText(),
            onEditingComplete: _commitText,
          ),
        ),
        const SizedBox(width: 8),
        circleButton(
          icon: Icons.add,
          enabled: canInc,
          onTap: () {
            var next = value + widget.step;
            if (max != null && next > max) next = max;
            widget.onChanged(next);
            _controller.text = _valueToText(next);
          },
        ),
      ],
    );
  }
}
