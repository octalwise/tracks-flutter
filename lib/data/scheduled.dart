import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:tracks/data/train.dart';
import 'package:tracks/data/stop.dart';

class ScheduledTrain {
  final int id;
  final String direction;
  final String route;

  const ScheduledTrain({
    required this.id,
    required this.direction,
    required this.route,
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

  Scheduled._(this.trains, this.stops);

  static Future<Scheduled> create() async {
    final res = await http.get(Uri.https('www.caltrain.com'));
    final data = res.body;
    final doc = html.parse(data);

    final la = tz.getLocation('America/Los_Angeles');
    final now = tz.TZDateTime.now(la);

    final shifted = now.subtract(const Duration(hours: 5));

    final weekend =
      shifted.weekday == DateTime.saturday
        || shifted.weekday == DateTime.sunday;

    final dayType = weekend ? 'weekend' : 'weekday';

    final trains = <ScheduledTrain>[];
    final stops = <ScheduledStop>[];

    for (final table in doc.querySelectorAll('table.caltrain_schedule tbody')) {
      final direction =
          table.parent!.attributes['data-direction'] == 'northbound' ? 'N' : 'S';

      for (final header in table.querySelectorAll(
        'tr:first-child td.schedule-trip-header[data-service-type=$dayType]',
      )) {
        final train = int.parse(header.attributes['data-trip-id']!);
        final fullRoute = header.attributes['data-route-id']!;

        final local = fullRoute == 'Local Weekday' || fullRoute == 'Local Weekend';
        final route = local ? 'Local' : fullRoute;

        trains.add(
          ScheduledTrain(id: train, direction: direction, route: route),
        );
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

          stops.add(
            ScheduledStop(station: stop, time: time, train: train),
          );
        }
      }
    }

    return Scheduled._(trains, stops);
  }

  Future<List<Train>> fetch() async {
    final now = DateTime.now();

    final allStops = stops.map((stop) {
      var time = DateTime(
        now.year,
        now.month,
        now.day,
        stop.time.hour,
        stop.time.minute,
        stop.time.second,
        stop.time.millisecond,
        stop.time.microsecond,
      );

      if (now.hour >= 4 && stop.time.hour < 4) {
        time = time.add(const Duration(days: 1));
      }

      if (now.hour <= 4 && stop.time.hour >= 4) {
        time = time.subtract(const Duration(days: 1));
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

        final min = trainStops.first.time;
        final max = trainStops.last.time;

        var location = null;

        if (min.isBefore(now) && max.isAfter(now)) {
          final stop = trainStops.firstWhere((stop) => stop.time.isBefore(now));

          location = stop.station;
        }

        return Train(
          id: train.id,
          live: false,

          direction: train.direction,
          route: train.route,
          location: location,

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
}
