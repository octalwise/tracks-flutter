import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:tracks/data/scheduled.dart';
import 'package:tracks/data/holidays.dart';

import 'package:tracks/widget/stations_view.dart';
import 'package:tracks/widget/trips_view.dart';
import 'package:tracks/widget/alerts_view.dart';

import 'package:tracks/state/trains.dart';
import 'package:tracks/state/stations.dart';
import 'package:tracks/state/alerts.dart';
import 'package:tracks/state/trips.dart';

class ContentView extends ConsumerStatefulWidget {
  ContentView({super.key});

  @override
  ConsumerState<ContentView> createState() => ContentViewState();
}

class ContentViewState extends ConsumerState<ContentView> {
  late Scheduled scheduled;
  Holidays? holidays;

  DateTime? lastUpdate = null;

  var currentTab = 1;

  Future fetch({bool? init}) async {
    if (init == true) {
      if (holidays == null) {
        holidays = await Holidays.create();
      }

      await ref.read(stationsProvider.notifier).fetch([]);
      scheduled = await Scheduled.create(holidays!);
    }

    final trains = await scheduled.fetch();
    ref.read(trainsProvider.notifier).fetch(trains);
  }

  @override
  void initState() {
    super.initState();

    tz.initializeTimeZones();

    fetch(init: true);
    ref.read(alertsProvider.notifier).fetch();

    Timer.periodic(
      Duration(seconds: 90),
      (t) => fetch(),
    );
    Timer.periodic(
      Duration(seconds: 180),
      (t) => ref.read(alertsProvider.notifier).fetch(),
    );
    Timer.periodic(
      Duration(seconds: 60),
      (t) {
        final now = DateTime.now();

        if (
          lastUpdate != null &&
          now.year == lastUpdate!.year &&
          now.month == lastUpdate!.month &&
          now.day == lastUpdate!.day
        ) {
          return;
        }

        if (now.hour == 5 && now.minute == 1) {
          fetch(init: true);
          lastUpdate = now;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(trainsProvider);
    ref.watch(stationsProvider);
    ref.watch(alertsProvider);
    ref.watch(tripsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetch,
        child: [
          TripsView(),
          StationsView(),
          AlertsView(),
        ][currentTab],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          setState(() => currentTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: const Icon(Icons.map_rounded),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_rounded),
            label: 'Stations',
          ),
          NavigationDestination(
            icon: const Icon(Icons.warning_rounded),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
