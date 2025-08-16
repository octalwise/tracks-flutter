import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracks/state/trains.dart';
import 'package:tracks/state/stations.dart';

import 'package:tracks/widget/app_bar.dart';
import 'package:tracks/widget/past_checkbox.dart';
import 'package:tracks/widget/stop_row.dart';
import 'package:tracks/widget/train_view.dart';

class StationView extends ConsumerStatefulWidget {
  final int id;

  const StationView({super.key, required this.id});

  @override
  ConsumerState<StationView> createState() => StationViewState();
}

class StationViewState extends ConsumerState<StationView> {
  var direction = 'N';
  var showPast = false;

  @override
  Widget build(BuildContext context) {
    final station = ref.read(stationsProvider.notifier).getStation(widget.id);

    final all = ref.read(trainsProvider.notifier).forStation(station, direction);
    final stopTrains =
      showPast
        ? all
        : all.where((stopTrain) {
            final (stop, _) = stopTrain;
            return !stop.expected.isBefore(DateTime.now());
          }).toList();

    ref.watch(trainsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BackBar(title: station.name),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedActionChip(
                      label: 'North',
                      selected: direction == 'N',
                      onTap: () {
                        setState(() => direction = 'N');
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: AnimatedActionChip(
                      label: 'South',
                      selected: direction == 'S',
                      onTap: () {
                        setState(() => direction = 'S');
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
            padding: const EdgeInsets.only(bottom: 32),
            sliver: SliverList.separated(
              itemCount: stopTrains.length,
              itemBuilder: (context, index) {
                final (stop, train) = stopTrains[index];
                final (foreground, background) = train.routeColor(context);

                return StopRow(
                  button: FilledButton.tonal(
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
                        Text(train.id.toString(), style: const TextStyle(fontSize: 16)),
                      ],
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

class AnimatedActionChip extends StatelessWidget {
  const AnimatedActionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final border = BorderSide(
      color:
        selected
          ? theme.colorScheme.secondaryContainer
          : theme.dividerColor.withValues(alpha: 0.4),
    );

    final fill =
      selected
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.surface;

    final radius = BorderRadius.circular(selected ? 32.0 : 8.0);

    final outer = RoundedRectangleBorder(borderRadius: radius, side: border);
    final inner = RoundedRectangleBorder(borderRadius: radius);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: ShapeDecoration(
        shape: outer,
        color: fill,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: inner,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[
                  Icon(Icons.check, size: 18),
                  SizedBox(width: 4),
                ],
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
