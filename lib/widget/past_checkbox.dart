import 'package:flutter/material.dart';

class PastCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  PastCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (value) => onChanged(value!),
            visualDensity: VisualDensity(horizontal: -2.0, vertical: -4.0),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
