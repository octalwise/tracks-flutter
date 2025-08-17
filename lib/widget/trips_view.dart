import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import 'package:tracks/state/trips.dart';
import 'package:tracks/state/stations.dart';

import 'package:tracks/widget/app_bar.dart';
import 'package:tracks/widget/train_view.dart';
import 'package:tracks/widget/past_checkbox.dart';

import 'package:tracks/data/stop.dart';
import 'package:tracks/data/train.dart';
import 'package:tracks/data/both_stations.dart';

class TripsView extends ConsumerStatefulWidget {
  const TripsView({super.key});

  @override
  ConsumerState<TripsView> createState() => TripsViewState();
}

class TripsViewState extends ConsumerState<TripsView> {
  var showPast = false;

  @override
  void initState() {
    super.initState();

    final all = ref.read(tripsProvider.notifier).getTrains();

    final nonPast =
      all.any((stopsTrain) {
        final (from, _, _) = stopsTrain;
        return !from.expected.isBefore(DateTime.now());
      });

    if (!nonPast) {
      showPast = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stations = ref.watch(stationsProvider);

    final all = ref.read(tripsProvider.notifier).getTrains();
    final stopsTrains =
      showPast
        ? all
        : all.where((stopsTrain) {
            final (from, _, _) = stopsTrain;
            return !from.expected.isBefore(DateTime.now());
          }).toList();

    ref.watch(tripsProvider);

    return CustomScrollView(
      slivers: [
        MainBar(title: 'Trips'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: StationPicker(
                    label: 'From Station',
                    selected: ref.watch(tripsProvider).from,
                    stations: stations,
                    onSelected: (station) {
                      ref.read(tripsProvider.notifier).setFrom(station);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.swap_horiz_rounded),
                    onPressed: () {
                      ref.read(tripsProvider.notifier).swap();
                    },
                  )
                ),
                Expanded(
                  child: StationPicker(
                    label: 'To Station',
                    selected: ref.watch(tripsProvider).to,
                    stations: stations,
                    onSelected: (station) {
                      ref.read(tripsProvider.notifier).setTo(station);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: PastCheckbox(
            label: 'Show Past Trains',
            value: showPast,
            onChanged: (value) {
              setState(() => showPast = value);
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: SliverList.separated(
            itemCount: stopsTrains.length,
            itemBuilder: (context, index) {
              final (from, to, train) = stopsTrains[index];

              return TripRow(
                from: from,
                to: to,
                train: train,
                past: from.expected.isBefore(DateTime.now()),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          ),
        ),
      ],
    );
  }
}

class StationPicker extends StatelessWidget {
  final String label;
  final BothStations? selected;

  final List<BothStations> stations;
  final ValueChanged<BothStations> onSelected;

  late final ScrollController controller;

  StationPicker({
    required this.label,
    required this.selected,
    required this.stations,
    required this.onSelected,
  }) {
    final index = stations.indexWhere(
      (station) => station == selected!,
    );

    controller = ScrollController(
      initialScrollOffset:
        stations.length > 9
          ? (index - 3.5).clamp(0, stations.length - 9) * 52
          : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Row(
        children: [
          Expanded(
            child: Text(
              selected?.name ?? label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Icon(Icons.expand_more_rounded),
        ],
      ),
      labelPadding: const EdgeInsets.only(left: 6),
      onPressed: () async {
        final chosen = await showModalBottomSheet<BothStations>(
          context: context,
          clipBehavior: Clip.antiAlias,
          builder: (context) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 8),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: stations.length,
                      itemBuilder: (context, index) {
                        final station = stations[index];
                        final focused = station == selected;

                        return ListTile(
                          title: Row(
                            children: [
                              if (focused) ...[
                                Icon(Icons.check, size: 18),
                                SizedBox(width: 8),
                              ],
                              Text(station.name),
                            ],
                          ),
                          visualDensity: VisualDensity(vertical: -1),
                          onTap: () => Navigator.pop(context, station),
                          tileColor:
                            focused
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );

        if (chosen != null) {
          onSelected(chosen);
        }
      },
    );
  }
}

class TripRow extends StatelessWidget {
  final Train train;
  final Stop from;
  final Stop to;
  final bool past;

  const TripRow({
    required this.train,
    required this.from,
    required this.to,
    required this.past,
  });

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = train.routeColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Opacity(
        opacity: past ? 0.6 : 1.0,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TrainView(id: train.id),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                    backgroundColor: WidgetStateProperty.all(background),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.train_rounded,
                        color: foreground,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        train.id.toString(),
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('h:mm a').format(from.expected),
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('h:mm a').format(to.expected),
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
