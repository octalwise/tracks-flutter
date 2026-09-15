import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tracks/data/train.dart';
import 'package:tracks/data/stop.dart';
import 'package:tracks/data/both_stations.dart';

import 'package:tracks/state/trains.dart';

part 'trips.g.dart';

class TripsState {
  final BothStations from;
  final BothStations to;

  const TripsState({required this.from, required this.to});
}

@riverpod
class Trips extends _$Trips {
  @override
  TripsState build() {
    SharedPreferences.getInstance().then((prefs) {
      final from = prefs.getStringList('from');
      final to = prefs.getStringList('to');

      if (from == null || to == null) return;

      state = TripsState(
        from: BothStations.compact(from[0], int.parse(from[1]), int.parse(from[2])),
        to: BothStations.compact(to[0], int.parse(to[1]), int.parse(to[2])),
      );
    });

    return TripsState(
      from: BothStations.compact('Palo Alto', 70171, 70172),
      to: BothStations.compact('San Mateo', 70091, 70092),
    );
  }

  List<(Stop, Stop, Train)> getTrains() {
    ref.watch(trainsProvider);

    final trains = ref.read(trainsProvider.notifier).getTrains();

    return trains
      .map((train) => (
        train.stops.firstWhereOrNull(
          (stop) => state.from.contains(stop.station),
        ),
        train.stops.firstWhereOrNull(
          (stop) => state.to.contains(stop.station),
        ),
        train,
      ))
      .where((stopsTrain) {
        final (from, to, _) = stopsTrain;

        return from != null && to != null &&
          from.expected.isBefore(to.expected);
      })
      .cast<(Stop, Stop, Train)>()
      .sortedBy((stopsTrain) => stopsTrain.$1)
      .toList();
  }

  void setFrom(BothStations station) {
    state = TripsState(from: station, to: state.to);
    save();
  }

  void setTo(BothStations station) {
    state = TripsState(from: state.from, to: station);
    save();
  }

  void swap() {
    state = TripsState(from: state.to, to: state.from);
    save();
  }

  Future save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('from', [state.from.name, state.from.north.id.toString(), state.from.south.id.toString()]);
    prefs.setStringList('to', [state.to.name, state.to.north.id.toString(), state.to.south.id.toString()]);
  }
}
