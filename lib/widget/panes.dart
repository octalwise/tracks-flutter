import 'package:flutter/material.dart';

class PaneScope extends InheritedWidget {
  final int index;

  const PaneScope({
    super.key,
    required this.index,
    required super.child,
  });

  static PaneScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<PaneScope>()!;

  @override
  bool updateShouldNotify(PaneScope old) => index != old.index;
}

class Panes extends StatefulWidget {
  final Widget root;
  final int tab;

  const Panes({super.key, required this.root, required this.tab});

  @override
  State<Panes> createState() => PanesState();

  static PanesState of(BuildContext context) => context.findAncestorStateOfType<PanesState>()!;
}

class PanesState extends State<Panes> {
  final List<Widget> panes = [];
  final controller = ScrollController();

  @override
  void didUpdateWidget(Panes oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.tab != oldWidget.tab) {
      truncate(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = [widget.root, ...panes];

    return ListView.separated(
      controller: controller,
      scrollDirection: Axis.horizontal,
      itemCount: all.length,
      separatorBuilder: (context, index) => const VerticalDivider(width: 1),
      itemBuilder: (context, index) {
        return SizedBox(
          width: 500,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: Size(500, MediaQuery.of(context).size.height),
              padding: EdgeInsets.zero,
            ),
            child: PaneScope(
              index: index,
              child: all[index],
            ),
          ),
        );
      },
    );
  }

  void truncate(int start) {
    panes.removeRange(start, panes.length);
  }

  void push(int index, Widget widget) {
    setState(() {
      if (panes.length > index) {
        truncate(index);
      }
      panes.add(widget);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
