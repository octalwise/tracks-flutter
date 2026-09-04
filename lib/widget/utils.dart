import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:tracks/widget/panes.dart';

String formatTime(BuildContext context, DateTime time) {
  final use24h = MediaQuery.of(context).alwaysUse24HourFormat;

  return use24h
      ? DateFormat('HH:mm').format(time)
      : DateFormat('h:mm a').format(time);
}

void pushView(BuildContext context, Widget widget) {
  final view = View.of(context);
  final width = view.physicalSize.width / view.devicePixelRatio;

  if (width > 700) {
    Panes.of(context).push(PaneScope.of(context).index, widget);
  } else {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => widget));
  }
}
