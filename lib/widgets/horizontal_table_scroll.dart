import 'package:flutter/material.dart';

class HorizontalTableScroll extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const HorizontalTableScroll({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<HorizontalTableScroll> createState() => _HorizontalTableScrollState();
}

class _HorizontalTableScrollState extends State<HorizontalTableScroll> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}
