import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:tracks/widget/content_view.dart';
import 'package:tracks/widget/panes.dart';

String formatTime(BuildContext context, DateTime time) {
  final laTime = tz.TZDateTime.from(time, tz.getLocation('America/Los_Angeles'));
  final use24h = MediaQuery.of(context).alwaysUse24HourFormat;

  return use24h
      ? DateFormat('HH:mm').format(laTime)
      : DateFormat('h:mm a').format(laTime);
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

tz.TZDateTime tzNow() {
  return tz.TZDateTime.now(tz.getLocation('America/Los_Angeles'));
}

class FABController extends ScrollController {
  FABController(BuildContext context) {
    addListener(() {
      final dir = position.userScrollDirection;
      final show = dir == ScrollDirection.forward;

      if (dir != ScrollDirection.idle) {
        ShowNotification(show).dispatch(context);
      }
    });
  }
}
