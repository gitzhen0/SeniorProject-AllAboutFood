import 'package:flutter/material.dart';

class FlowWrapper {
  static void push(
    BuildContext context,
    Widget toPush,
  ) {
    Navigator.of(context).push(MaterialPageRoute<Widget>(builder: (context) => toPush));
  }

  static void pushNoTransition(
    BuildContext context,
    Widget toPush,
  ) {
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => toPush,
          transitionDuration: Duration.zero,
        ));
  }
}
