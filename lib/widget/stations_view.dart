import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracks/data/train.dart';

import 'package:tracks/data/both_stations.dart';

import 'package:tracks/state/trains.dart';
import 'package:tracks/state/stations.dart';

import 'package:tracks/widget/app_bar.dart';
import 'package:tracks/widget/train_view.dart';
import 'package:tracks/widget/station_view.dart';

class StationsView extends ConsumerStatefulWidget {
  const StationsView({super.key});

  @override
  ConsumerState<StationsView> createState() => StationsViewState();
}

class StationsViewState extends ConsumerState<StationsView> {
  Timer? refresh;

  @override
  void initState() {
    super.initState();

    refresh = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (mounted) setState(() {});
      }
    );
  }

  @override
  void dispose() {
    refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(trainsProvider);
    final stations = ref.watch(stationsProvider);

    ref.watch(trainsProvider);
    ref.watch(stationsProvider);

    return CustomScrollView(
      slivers: [
        MainBar(title: 'Stations'),
        SliverPadding(
          padding: EdgeInsets.only(top: 4, bottom: 12),
          sliver: SliverList.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];

              final north =
                station.north.train != null
                  ? ref.read(trainsProvider.notifier).getTrain(station.north.train!)
                  : null;

              final south =
                station.south.train != null
                  ? ref.read(trainsProvider.notifier).getTrain(station.south.train!)
                  : null;

              return StationsRow(
                station: station,
                north: north,
                south: south,
              );
            },
          ),
        ),
      ],
    );
  }
}

class StationsRow extends StatelessWidget {
  final BothStations station;

  final Train? north;
  final Train? south;

  const StationsRow({
    required this.station,
    required this.north,
    required this.south,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          south != null
            ? TrainIcon(train: south!)
            : Expanded(
                flex: 5,
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
              ),

          Expanded(
            flex: 12,
            child: FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StationView(id: station.north.id),
                  ),
                );
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
              child: Text(
                station.name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          north != null
            ? TrainIcon(train: north!)
            : Expanded(
                flex: 5,
                child: const Icon(Icons.keyboard_arrow_up_rounded, size: 32),
              ),
        ],
      ),
    );
  }
}

class TrainIcon extends StatelessWidget {
  final Train train;

  const TrainIcon({required this.train});

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = train.routeColor(context);

    return Expanded(
      flex: 5,
      child: Center(
        child: IconButton.filled(
          icon: const Icon(Icons.train_rounded),
          color: foreground,
          style: IconButton.styleFrom(
            backgroundColor: background,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TrainView(id: train.id),
              ),
            );
          },
        ),
      ),
    );
  }
}
