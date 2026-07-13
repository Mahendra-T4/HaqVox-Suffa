import 'package:flutter/material.dart';

class ModernBaseLayout extends StatelessWidget {
  final Widget child;
  final bool showMiniPlayer;
  final PreferredSizeWidget? appBar;

  const ModernBaseLayout({
    Key? key,
    required this.child,
    this.showMiniPlayer = true,
    this.appBar,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: child,
    );
  }
}
