import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:http/http.dart' as http;

import 'package:tracks/data/alert.dart';

part 'alerts.g.dart';

@riverpod
class Alerts extends _$Alerts {
  @override
  List<Alert> build() => [];

  Future fetch() async {
    final url = Uri.https('tracks-api.octalwise.com', '/alerts');
    final token = const String.fromEnvironment('API_KEY');

    final res = await http.get(url, headers: {'Authorization': token});
    final dyn = json.decode(res.body);

    final alerts = List<Alert>.from(dyn.map((data) => Alert.fromJson(data)));
    state = alerts;
  }
}
