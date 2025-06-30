import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracks/state/alerts.dart';

import 'package:tracks/widget/app_bar.dart';

class AlertsView extends ConsumerWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MainBar(title: 'Alerts'),
          SliverPadding(
            padding: EdgeInsets.only(top: 4, bottom: 12),
            sliver: SliverList.separated(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];

                final header = Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.info_rounded),
                    ),
                    Expanded(
                      child: Text(
                        alert.header,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ]
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child:
                    alert.description == null || alert.description!.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: header,
                        )
                      : Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            title: header,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    alert.description!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                            childrenPadding: const EdgeInsets.only(bottom: 8),
                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(height: 24);
              },
            ),
          ),
        ],
      )
    );
  }
}
