import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dynamic_color/dynamic_color.dart';

import 'package:tracks/widget/content_view.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return FutureBuilder(
      future: DynamicColorPlugin.getCorePalette(),
      builder: (context, snapshot) {
        final color = snapshot.data?.primary.get(40);
        final seed = Color(color ?? 0xff6750a4);

        return MaterialApp(
          themeMode: ThemeMode.system,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.light,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              },
            ),
            dividerTheme: DividerThemeData(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
            ),
            segmentedButtonTheme: SegmentedButtonThemeData(
              style: ButtonStyle(
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.4)
                  ),
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.dark,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              },
            ),
            dividerTheme: DividerThemeData(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
            ),
            segmentedButtonTheme: SegmentedButtonThemeData(
              style: ButtonStyle(
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.4)
                  ),
                ),
              ),
            ),
          ),
          home: ContentView(),
        );
      },
    );
  }
}
