import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracks/state/alerts.dart';

import 'package:tracks/widget/app_bar.dart';

class AlertsView extends ConsumerWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);

    return CustomScrollView(
      slivers: [
        MainBar(title: 'Alerts'),
        SliverPadding(
          padding: EdgeInsets.only(top: 4, bottom: 12, left: 16, right: 16),
          sliver: SliverList.separated(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];

              return Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.info_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        alert.header,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (alert.description != null && alert.description!.isNotEmpty)
                        Text(
                          alert.description!,
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 24),
          ),
        ),
      ],
    );
  }
}
