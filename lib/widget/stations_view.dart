import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracks/data/train.dart';
import 'package:tracks/data/both_stations.dart';

import 'package:tracks/state/trains.dart';
import 'package:tracks/state/stations.dart';
import 'package:tracks/state/service.dart';

import 'package:tracks/widget/app_bar.dart';
import 'package:tracks/widget/train_view.dart';
import 'package:tracks/widget/station_view.dart';
import 'package:tracks/widget/utils.dart';

class StationsView extends ConsumerStatefulWidget {
  const StationsView({super.key});

  @override
  ConsumerState<StationsView> createState() => StationsViewState();
}

class StationsViewState extends ConsumerState<StationsView> {
  Timer? refresh;

  late FABController controller;

  @override
  void initState() {
    super.initState();

    refresh = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        if (mounted) setState(() {});
      }
    );

    controller = FABController(context);
  }

  @override
  void dispose() {
    refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stations = ref.watch(stationsProvider);
    final altService = ref.read(serviceProvider.notifier).alt();

    ref.watch(trainsProvider);
    ref.watch(serviceProvider);

    return CustomScrollView(
      controller: controller,
      slivers: [
        MainBar(title: 'Stations'),
        SliverPadding(
          padding: EdgeInsets.only(top: 4, bottom: 12),
          sliver: SliverToBoxAdapter(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final station in stations)
                      StationsRow(station: station),
                  ],
                ),
                for (final (i, station) in stations.indexed)
                  if (station.north.train != null || station.south.train != null)
                    Positioned(
                      top: (i - 1) * 44 - 48,
                      left: 0,
                      right: 0,
                      height: 92 + 44 * 2,
                      child: TrainsRow(
                        north: station.north.train != null
                          ? ref.read(trainsProvider.notifier).getTrain(station.north.train!)
                          : null,
                        south: station.south.train != null
                          ? ref.read(trainsProvider.notifier).getTrain(station.south.train!)
                          : null,
                        altService: altService,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StationsRow extends StatelessWidget {
  final BothStations station;

  const StationsRow({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            ),
            Expanded(
              flex: 12,
              child: FilledButton.tonal(
                onPressed: () {
                  pushView(context, StationView(id: station.north.id));
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
            Expanded(
              flex: 5,
              child: const Icon(Icons.keyboard_arrow_up_rounded, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class TrainsRow extends StatelessWidget {
  final Train? north;
  final Train? south;

  final bool altService;

  const TrainsRow({
    super.key,
    required this.north,
    required this.south,
    required this.altService,
  });

  Widget slot(Train? train, double dy) {
    return train != null
      ? Padding(
          padding: EdgeInsets.only(top: 44 + (train.offset ? 44 * dy : 0)),
          child: Align(
            alignment: Alignment.topCenter,
            child: TrainIcon(train: train, altService: altService),
          ),
        )
      : SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 5, child: slot(south, 1)),
        Expanded(flex: 12, child: SizedBox()),
        Expanded(flex: 5, child: slot(north, -1)),
      ],
    );
  }
}

class TrainIcon extends StatelessWidget {
  final Train train;
  final bool altService;

  const TrainIcon({
    super.key,
    required this.train,
    required this.altService,
  });

  @override
  Widget build(BuildContext context) {
    var (foreground, background) = train.routeColor(context);

    if (altService) {
      final surface = Theme.of(context).colorScheme.surface;
      foreground = Color.alphaBlend(foreground.withValues(alpha: 0.6), surface);
      background = Color.alphaBlend(background.withValues(alpha: 0.6), surface);
    }

    return Center(
      child: IconButton.filled(
        icon: const Icon(Icons.train_rounded),
        color: foreground,
        style: IconButton.styleFrom(
          backgroundColor: background,
        ),
        onPressed: () {
          pushView(context, TrainView(id: train.id));
        },
      ),
    );
  }
}
