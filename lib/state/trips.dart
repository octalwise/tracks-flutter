import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:collection/collection.dart';

import 'package:tracks/data/train.dart';
import 'package:tracks/data/stop.dart';
import 'package:tracks/data/station.dart';
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
    return TripsState(
      from: BothStations(name: 'Palo Alto', north: Station(id: 70171), south: Station(id: 70172)),
      to:   BothStations(name: 'San Mateo', north: Station(id: 70091), south: Station(id: 70092)),
    );
  }

  List<(Stop, Stop, Train)> getTrains() {
    final trains = ref.read(trainsProvider);

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
  }

  void setTo(BothStations station) {
    state = TripsState(from: state.from, to: station);
  }

  void swap() {
    state = TripsState(from: state.to, to: state.from);
  }
}
