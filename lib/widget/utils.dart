import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

String formatTime(BuildContext context, DateTime time) {
  final use24h = MediaQuery.of(context).alwaysUse24HourFormat;

  return use24h
      ? DateFormat('HH:mm').format(time)
      : DateFormat('h:mm a').format(time);
}
