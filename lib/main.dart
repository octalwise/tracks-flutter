import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracks/data/stations_data.dart';
import 'package:tracks/widget/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ensureStations();

  runApp(const ProviderScope(child: Home()));
}
