import 'package:flutter/material.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:tracks/data/stations_data.dart';

import 'package:tracks/data/stop.dart';
import 'package:tracks/state/service.dart';
import 'package:tracks/widget/utils.dart';

part 'train.g.dart';

@JsonSerializable()
class Train {
  final int id;
  final bool live;
  final String direction;
  final String route;
  final ServiceType service;
  @JsonKey(includeFromJson: false)
  int? location;
  @JsonKey(includeFromJson: false)
  bool offset;
  final List<Stop> stops;

  Train({
    required this.id,
    required this.live,
    required this.direction,
    required this.route,
    required this.service,
    required this.stops,
    this.offset = false,
    this.location,
  });

  factory Train.fromJson(Map<String, dynamic> json) => _$TrainFromJson(json).updatedLocation();

  factory Train.located({
    required int id,
    required bool live,
    required String direction,
    required String route,
    required ServiceType service,
    required List<Stop> stops,
  }) {
    final (location, offset) = _getLocation(direction, stops);

    return Train(
      id: id,
      live: live,
      direction: direction,
      route: route,
      service: service,
      stops: stops,
      location: location,
      offset: offset,
    );
  }

  Train updatedLocation() {
    return Train.located(
      id: id,
      live: live,
      direction: direction,
      route: route,
      service: service,
      stops: stops,
    );
  }

  void refresh() {
    final (newLoc, newOffset) = _getLocation(direction, stops);

    location = newLoc;
    offset = newOffset;
  }

  static (int?, bool) _getLocation(String direction, List<Stop> stops) {
    final now = tzNow();

    if (!now.isAfter(stops.first.expected) || !now.isBefore(stops.last.expected)) {
      return (null, false);
    }

    final nextIdx = stops.indexWhere((s) => s.expected.isAfter(now));

    final nextStop = stops[nextIdx];
    final prevStop = stops[nextIdx - 1];

    final idx1 = stations.indexWhere((s) => s.contains(prevStop.station));
    final idx2 = stations.indexWhere((s) => s.contains(nextStop.station));

    if (now.isAfter(nextStop.expected.subtract(const Duration(seconds: 20)))) {
      return (stations[idx2].side(direction), false);
    } else {
      final dt = nextStop.expected.difference(prevStop.expected).inMilliseconds;
      final mix = (now.difference(prevStop.expected).inMilliseconds / dt).clamp(0.0, 1.0);

      final offset = mix * (idx2 - idx1);
      final frac = offset - offset.truncate();

      return (stations[idx1 + offset.truncate()].side(direction), frac.abs() > 0.25);
    }
  }

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
