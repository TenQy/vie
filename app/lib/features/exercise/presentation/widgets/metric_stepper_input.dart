import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';

class MetricStepperInput extends StatefulWidget {
  final String label;
  final num value;
  final bool isDecimal;
  final double step;
  final num minValue;
  final ValueChanged<num> onChanged;

  const MetricStepperInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isDecimal = false,
    this.step = 1.0,
    this.minValue = 0,
  });

  @override
  State<MetricStepperInput> createState() => _MetricStepperInputState();
}

class _MetricStepperInputState extends State<MetricStepperInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant MetricStepperInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      final parsed = _parse(_controller.text);
      if (parsed == null) {
        _controller.text = _format(widget.value);
      } else {
        final clamped = parsed < widget.minValue ? widget.minValue : parsed;
        _controller.text = _format(clamped);
        widget.onChanged(clamped);
      }
    }
  }

  String _format(num val) {
    if (widget.isDecimal) {
      return val % 1 == 0 ? val.toInt().toString() : val.toString();
    }
    return val.toInt().toString();
  }

  num? _parse(String text) {
    if (widget.isDecimal) {
      return double.tryParse(text.replaceAll(',', '.'));
    }
    return int.tryParse(text);
  }

  void _step(double delta) {
    final current = _parse(_controller.text) ?? widget.value;
    final next = (current + delta).clamp(widget.minValue, 9999.0);
    final finalVal = widget.isDecimal ? next : next.round();
    _controller.text = _format(finalVal);
    widget.onChanged(finalVal);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.minus, size: 16),
                onPressed: () => _step(-widget.step),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  style: AppTypography.titleMedium.copyWith(fontSize: 18),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: widget.isDecimal,
                  ),
                  inputFormatters: [
                    if (widget.isDecimal)
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*'))
                    else
                      FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                  ),
                  onChanged: (text) {
                    final parsed = _parse(text);
                    if (parsed != null && parsed >= widget.minValue) {
                      widget.onChanged(parsed);
                    }
                  },
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.plus, size: 16),
                onPressed: () => _step(widget.step),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
