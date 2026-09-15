import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PastCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PastCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final addl = kIsWeb ? 4.0 : 0.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(8 + addl, addl, 8 + addl, 14 + addl),
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
