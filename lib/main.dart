import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:tracks/data/stations_data.dart';
import 'package:tracks/state/prefs.dart';
import 'package:tracks/widget/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ensureStations();

  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: Home(),
  ));
}
