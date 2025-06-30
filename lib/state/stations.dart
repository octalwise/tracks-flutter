import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:collection/collection.dart';

import 'package:tracks/data/station.dart';
import 'package:tracks/data/train.dart';
import 'package:tracks/data/both_stations.dart';
import 'package:tracks/data/station_info.dart';

part 'stations.g.dart';

@riverpod
class Stations extends _$Stations {
  @override
  List<BothStations> build() => [];

  void fetch(List<Train> trains) async {
    final data = await rootBundle.loadString('assets/stations.json');

    final List<dynamic> dyn = json.decode(data);
    final infos = dyn.map((data) => StationInfo.fromJson(data)).toList();

    final stations = infos.map((station) {
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

    state = stations;
  }

  BothStations getStation(int stationID) {
    return state.firstWhere((station) => station.contains(stationID));
  }
}
