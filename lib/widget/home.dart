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
                TargetPlatform.android: SlideBuilder(),
                TargetPlatform.macOS: SlideBuilder(),
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
            visualDensity: VisualDensity.standard,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.dark,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: SlideBuilder(),
                TargetPlatform.macOS: SlideBuilder(),
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
            visualDensity: VisualDensity.standard,
          ),
          home: ContentView(),
        );
      },
    );
  }
}

class SlideBuilder extends PageTransitionsBuilder {
  const SlideBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    Curve push = Cubic(0.0, 0.0, 0.4, 1.0);
    Curve pop = Cubic(0.4, 0.0, 1.0, 1.0);

    final primary = CurvedAnimation(
      parent: animation,
      curve: push,
      reverseCurve: pop,
    );

    final secondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: push,
      reverseCurve: pop,
    );

    return SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(primary),

      child: SlideTransition(
        position: Tween(
          begin: Offset.zero,
          end: const Offset(-0.25, 0),
        ).animate(secondary),

        child: child,
      ),
    );
  }
}
