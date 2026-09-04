import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:collection/collection.dart';

import 'package:tracks/data/station.dart';
import 'package:tracks/data/stations_data.dart';
import 'package:tracks/data/both_stations.dart';
import 'package:tracks/data/train.dart';

part 'stations.g.dart';

@riverpod
class Stations extends _$Stations {
  @override
  List<BothStations> build() => [];

  Future fetch(List<Train> trains) async {
    state = stations.map((station) {
      return BothStations(
        name: station.name,
        north: Station(
          id: station.north,
          train: trains.firstWhereOrNull(
            (train) => train.location == station.north,
          )?.id,
        ),
        south: Station(
          id: station.south,
          train: trains.firstWhereOrNull(
            (train) => train.location == station.south,
          )?.id,
        ),
      );
    }).toList();
  }

  BothStations getStation(int stationID) {
    return state.firstWhere((station) => station.contains(stationID));
  }
}
