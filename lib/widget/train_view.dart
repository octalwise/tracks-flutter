import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracks/state/trains.dart';
import 'package:tracks/state/stations.dart';

import 'package:tracks/widget/app_bar.dart';
import 'package:tracks/widget/past_checkbox.dart';
import 'package:tracks/widget/stop_row.dart';
import 'package:tracks/widget/station_view.dart';

class TrainView extends ConsumerStatefulWidget {
  final int id;

  const TrainView({super.key, required this.id});

  @override
  ConsumerState<TrainView> createState() => TrainViewState();
}

class TrainViewState extends ConsumerState<TrainView> {
  bool showPast = false;

  @override
  Widget build(BuildContext context) {
    final train = ref.read(trainsProvider.notifier).getTrain(widget.id);

    final stops =
      showPast
        ? train.stops
        : train.stops.where((stop) {
            return !stop.expected.isBefore(DateTime.now());
          }).toList();

    ref.watch(trainsProvider);

    final (foreground, background) = train.routeColor(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BackBar(title: 'Train ${train.id}${!train.live ? '*' : ''}'),
          SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
              children: [
                PastCheckbox(
                  label: 'Show Past Stops',
                  value: showPast,
                  onChanged: (value) {
                    setState(() => showPast = value);
                  },
                ),
                Expanded(child: SizedBox()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Chip(
                    label: Text(train.route),
                    labelStyle: TextStyle(color: foreground),
                    backgroundColor: background,
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.transparent),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 32),
            sliver: SliverList.separated(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                final station = ref.read(stationsProvider.notifier).getStation(stop.station);

                return StopRow(
                  button: FilledButton.tonal(
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

                  time:  stop.expected,
                  delay: stop.expected.difference(stop.scheduled).inMinutes,

                  past: stop.expected.isBefore(DateTime.now()),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            ),
          ),
        ],
      ),
    );
  }
}
