import 'package:flutter/material.dart';

class MainBar extends StatelessWidget {
  final String title;

  const MainBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 150,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(title),
        titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
      ),
    );
  }
}

class BackBar extends StatelessWidget {
  final String title;

  const BackBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 150,
      flexibleSpace: LayoutBuilder(
        builder: (ctx, constraints) {
          final double max = 150 + MediaQuery.of(ctx).padding.top;
          final double min = kToolbarHeight + MediaQuery.of(ctx).padding.top;

          final double cur = constraints.maxHeight;

          final double x = (
            1 - (cur - min) / (max - min)
          ).clamp(0, 1);

          return FlexibleSpaceBar(
            title: Text(title),
            titlePadding: EdgeInsets.only(
              left:   16 + (56 - 16) * x,
              right:  16 + (56 - 16) * x,
              bottom: 14 + (14 - 14) * x,
            ),
          );
        },
      )
    );
  }
}
