import 'package:flutter/material.dart';

import 'package:tracks/widget/utils.dart';

class StopRow extends StatelessWidget {
  final Widget button;

  final DateTime time;
  final int delay;

  final bool past;

  const StopRow({
    required this.button,
    required this.time,
    required this.delay,
    required this.past,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Opacity(
        opacity: past ? 0.6 : 1.0,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: button,
              ),
            ),
            if (delay > 0)
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Chip(
                    label: Text('+$delay'),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.transparent),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  formatTime(context, time),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
