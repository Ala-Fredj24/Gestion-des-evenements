import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool centerContent;
  final EdgeInsetsGeometry padding;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.centerContent = false,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Padding(
        padding: padding,
        child: centerContent ? Center(child: child) : child,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: body,
    );
  }
}
