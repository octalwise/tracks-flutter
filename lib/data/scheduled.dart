import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:tracks/data/stations_data.dart';

import 'package:tracks/data/train.dart';
import 'package:tracks/data/stop.dart';
import 'package:tracks/data/holidays.dart';

import 'package:tracks/state/service.dart';

import 'package:tracks/widget/utils.dart';

class ScheduledTrain {
  final int id;
  final String direction;
  final String route;
  final ServiceType service;

  const ScheduledTrain({
    required this.id,
    required this.direction,
    required this.route,
    required this.service,
  });
}

class ScheduledStop {
  final int station;
  final DateTime time;
  final int train;

  const ScheduledStop({
    required this.station,
    required this.time,
    required this.train,
  });
}

class Scheduled {
  final List<ScheduledTrain> trains;
  final List<ScheduledStop> stops;

  const Scheduled._(this.trains, this.stops);

  static Future<String> data() async {
    http.Response res;

    if (kIsWeb) {
      final url = Uri.https('tracks-api.octalwise.com', '/caltrain/index');
      final token = const String.fromEnvironment('API_KEY');
      res = await http.get(url, headers: {'Authorization': token});
    } else {
      res = await http.get(Uri.https('www.caltrain.com'));
    }

    return utf8.decode(res.bodyBytes, allowMalformed: true);
  }

  static Future<Scheduled> parse(String data, Holidays holidays) async {
    final doc = html.parse(data);

    final trains = <ScheduledTrain>[];
    final stops = <ScheduledStop>[];

    for (final table in doc.querySelectorAll('table.caltrain_schedule tbody')) {
      final direction =
          table.parent!.attributes['data-direction'] == 'northbound' ? 'N' : 'S';

      for (final header in table.querySelectorAll(
        'tr:first-child td.schedule-trip-header',
      )) {
        final train = int.parse(header.attributes['data-trip-id']!);
        final fullRoute = header.attributes['data-route-id']!;
        final service = ServiceType.from(header.attributes['data-service-type']!);

        final local = fullRoute == 'Local Weekday' || fullRoute == 'Local Weekend';
        final route = local ? 'Local' : fullRoute;

        trains.add(ScheduledTrain(id: train, direction: direction, route: route, service: service));
      }

      for (final row in table.querySelectorAll('tr[data-stop-id]')) {
        final stop = int.parse(row.attributes['data-stop-id']!);

        for (final timepoint in row.querySelectorAll('td.timepoint')) {
          if (timepoint.text == '--') {
            continue;
          }

          final train = int.parse(timepoint.attributes['data-trip-id']!);

          final formatter = DateFormat('h:mma');
          final time = formatter.parseStrict(timepoint.text.toUpperCase());

          stops.add(ScheduledStop(station: stop, time: time, train: train));
        }
      }
    }

    return Scheduled._(trains, stops);
  }

  Future<List<Train>> fetch() async {
    final now = tzNow();

    final allStops = stops.map((stop) {
      var time = tz.TZDateTime(
        tz.getLocation('America/Los_Angeles'),
        now.year,
        now.month,
        now.day,
        stop.time.hour,
        stop.time.minute,
        stop.time.second,
        stop.time.millisecond,
        stop.time.microsecond,
      );

      final cutoff = 3;

      if (now.hour < cutoff && stop.time.hour >= cutoff) {
        time = time.subtract(const Duration(days: 1));
      } else if (now.hour >= cutoff && stop.time.hour < cutoff) {
        time = time.add(const Duration(days: 1));
      }

      return ScheduledStop(
        station: stop.station,
        time: time,
        train: stop.train,
      );
    });

    return List<Train>.of(
      trains.map((train) {
        final trainStops = allStops.where((stop) => stop.train == train.id).toList();
        trainStops.sort((a, b) => a.time.compareTo(b.time));

        final (location, offset) = getLocation(train.direction, trainStops);

        return Train(
          id: train.id,
          live: false,
          direction: train.direction,
          route: train.route,
          service: train.service,
          location: location,
          offset: offset,
          stops: List<Stop>.of(
            trainStops.map((stop) {
              return Stop(
                station: stop.station,
                scheduled: stop.time,
                expected: stop.time,
              );
            }),
          ),
        );
      },
    ));
  }

  (int?, bool) getLocation(String direction, List<ScheduledStop> stops) {
    final now = tzNow();

    if (stops.first.time.isAfter(now) || stops.last.time.isBefore(now)) {
      return (null, false);
    }

    final nextIdx = stops.indexWhere((s) => s.time.isAfter(now));

    final nextStop = stops[nextIdx];
    final prevStop = stops[nextIdx - 1];

    final idx1 = stations.indexWhere((s) => s.contains(prevStop.station));
    final idx2 = stations.indexWhere((s) => s.contains(nextStop.station));

    if (now.isAfter(nextStop.time.subtract(const Duration(seconds: 20)))) {
      return (stations[idx2].side(direction), false);
    } else {
      final dt = nextStop.time.difference(prevStop.time).inMilliseconds;
      final mix = (now.difference(prevStop.time).inMilliseconds / dt).clamp(0.0, 1.0);

      final offset = mix * (idx2 - idx1);
      final frac = offset - offset.truncate();

      return (stations[idx1 + offset.truncate()].side(direction), frac.abs() > 0.25);
    }
  }
}
