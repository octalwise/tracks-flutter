import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tracks/data/station_info.dart';

final Future<List<StationInfo>> fut = loadStations();
List<StationInfo>? cache;

List<StationInfo> get stations => cache!;

Future<List<StationInfo>> loadStations() async {
  final data = await rootBundle.loadString('assets/stations.json');
  final List<dynamic> dyn = json.decode(data);
  return dyn.map((data) => StationInfo.fromJson(data)).toList();
}

Future<void> ensureStations() async {
  cache ??= await fut;
}
