import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:tracks/data/scheduled.dart';
import 'package:tracks/data/holidays.dart';
import 'package:tracks/data/train.dart';

import 'package:tracks/widget/panes.dart';
import 'package:tracks/widget/stations_view.dart';
import 'package:tracks/widget/trips_view.dart';
import 'package:tracks/widget/alerts_view.dart';

import 'package:tracks/state/trains.dart';
import 'package:tracks/state/stations.dart';
import 'package:tracks/state/alerts.dart';
import 'package:tracks/state/trips.dart';

class ContentView extends ConsumerStatefulWidget {
  const ContentView({super.key});

  @override
  ConsumerState<ContentView> createState() => ContentViewState();
}

class ContentViewState extends ConsumerState<ContentView> {
  late Scheduled scheduled;
  Holidays? holidays;

  DateTime? lastUpdate;

  var currentTab = 1;

  Future fetch({bool? init}) async {
    String data;

    if (init == true) {
      final trainsFut = Trains.data();
      final scheduleFut = Scheduled.data();
      final holidayFut =
        holidays == null
          ? Holidays.create()
          : Future.value(holidays!);

      final (
        trainsData,
        scheduleData,
        holidaysData,
      ) = await (trainsFut, scheduleFut, holidayFut).wait;

      data = trainsData;
      holidays = holidaysData;
      scheduled = await Scheduled.parse(scheduleData, holidaysData);
    } else {
      data = await Trains.data();
    }

    final trains = await scheduled.fetch();
    ref.read(trainsProvider.notifier).parse(data, trains);
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

        if (now.hour >= 3) {
          fetch(init: true);
          lastUpdate = now;
        }
      },
    );
  }

  static const destinations = [
    (icon: Icon(Icons.map_rounded), label: 'Trips'),
    (icon: Icon(Icons.home_rounded), label: 'Stations'),
    (icon: Icon(Icons.warning_rounded), label: 'Alerts'),
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(trainsProvider);
    ref.watch(stationsProvider);
    ref.watch(alertsProvider);
    ref.watch(tripsProvider);

    final wide = MediaQuery.of(context).size.width >= 700;

    final body = RefreshIndicator(
      onRefresh: fetch,
      child: [
        TripsView(),
        StationsView(),
        AlertsView(),
      ][currentTab],
    );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentTab,
              onDestinationSelected: (index) {
                setState(() => currentTab = index);
              },
              labelType: NavigationRailLabelType.all,
              destinations:
                destinations
                  .map((d) => NavigationRailDestination(icon: d.icon, label: Text(d.label)))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: Panes(root: body, tab: currentTab)),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          setState(() => currentTab = index);
        },
        destinations:
          destinations
            .map((d) => NavigationDestination(icon: d.icon, label: d.label))
            .toList(),
      ),
    );
  }
}
