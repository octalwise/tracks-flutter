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

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          themeMode: ThemeMode.system,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: lightDynamic,

            navigationBarTheme: NavigationBarThemeData(
              surfaceTintColor: lightDynamic?.surfaceTint,
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
            colorScheme: darkDynamic,

            navigationBarTheme: NavigationBarThemeData(
              surfaceTintColor: darkDynamic?.surfaceTint,
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
