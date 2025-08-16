import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

import 'package:tracks/data/stop.dart';
import 'package:tracks/data/train.dart';
import 'package:tracks/data/both_stations.dart';

import 'package:tracks/state/stations.dart';

part 'trains.g.dart';

@riverpod
class Trains extends _$Trains {
  @override
  List<Train> build() => [];

  Future fetch(List<Train> scheduled) async {
    try {
      final url = Uri.https('tracks-api.octalwise.com', '/trains');
      final token = const String.fromEnvironment('API_KEY');

      final res = await http.get(url, headers: {'Authorization': token});
      final dyn = json.decode(res.body);

      final trains = List<Train>.from(dyn.map((data) => Train.fromJson(data)));
      final ids = trains.map((train) => train.id);

      state = [
        ...scheduled.where((train) => !ids.contains(train.id)).toList(),
        ...trains,
      ];
    } catch (e) {
      state = scheduled;
    }

    ref.read(stationsProvider.notifier).fetch(state);
  }

  Train getTrain(int trainID) {
    return state.firstWhere((train) => train.id == trainID);
  }

  List<(Stop, Train)> forStation(BothStations station, String direction) {
    final stationID = direction == 'N' ? station.north.id : station.south.id;

    return state
      .map((train) => (
        train.stops.firstWhereOrNull(
          (stop) => stop.station == stationID,
        ),
        train,
      ))
      .where((stopTrain) => stopTrain.$1 != null)
      .cast<(Stop, Train)>()
      .sortedBy((stopTrain) => stopTrain.$1)
      .toList();
  }
}
