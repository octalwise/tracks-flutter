import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracks/widget/home.dart';

void main() => runApp(
  const ProviderScope(child: const Home()),
);
