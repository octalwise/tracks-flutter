import 'package:flutter/material.dart';

import 'package:json_annotation/json_annotation.dart';

import 'package:tracks/data/stop.dart';

part 'train.g.dart';

@JsonSerializable()
class Train {
  final int id;
  final bool live;
  final String direction;
  final String route;
  final int? location;
  final List<Stop> stops;

  Train({
    required this.id,
    required this.live,
    required this.direction,
    required this.route,
    required this.stops,
    this.location = null,
  });

  factory Train.fromJson(Map<String, dynamic> json) => _$TrainFromJson(json);

  Map<String, dynamic> toJson() => _$TrainToJson(this);

  (Color, Color) routeColor(BuildContext context) {
    final light = {
      'Local':        (Colors.grey.shade800,   Colors.grey.shade300),
      'Limited':      (Colors.cyan.shade900,   Colors.cyan.shade50),
      'Express':      (Colors.red.shade900,    Colors.red.shade50),
      'South County': (Colors.yellow.shade900, Colors.yellow.shade100),
    };

    final dark = {
      'Local':        (Colors.grey.shade400,   Colors.grey.shade700),
      'Limited':      (Colors.cyan.shade100,   Colors.cyan.shade800),
      'Express':      (Colors.red.shade100,    Colors.red.shade700),
      'South County': (Colors.yellow.shade100, Colors.yellow.shade800),
    };

    final darkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final theme = darkMode ? dark : light;

    return theme[route] ?? theme['Local']!;
  }
}
