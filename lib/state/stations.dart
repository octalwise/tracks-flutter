import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:collection/collection.dart';

import 'package:tracks/state/trains.dart';

import 'package:tracks/data/station.dart';
import 'package:tracks/data/stations_data.dart';
import 'package:tracks/data/both_stations.dart';

part 'stations.g.dart';

@riverpod
class Stations extends _$Stations {
  @override
  List<BothStations> build() {
    final trains = ref.watch(trainsProvider);

    return stations.map((station) {
      return BothStations(
        name: station.name,
        north: Station(
          id: station.north,
          train: trains.firstWhereOrNull((t) => t.location == station.north)?.id,
        ),
        south: Station(
          id: station.south,
          train: trains.firstWhereOrNull((t) => t.location == station.south)?.id,
        ),
      );
    }).toList();
  }

  BothStations getStation(int stationID) {
    return state.firstWhere((station) => station.contains(stationID));
  }
}
