import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LikeAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimation;
  final Duration duration;
  final VoidCallback? onEnd;
  final bool smallike;
  const LikeAnimation({
    super.key,
    required this.child,
    required this.isAnimation,
    this.duration = const Duration(milliseconds: 150),
    this.onEnd,
    this.smallike = false,
  });

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ 2),
    );
    scale = Tween<double>(begin: 1, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(LikeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimation != oldWidget.isAnimation) {
      startAnimation();
    }
  }

  @override
  void startAnimation() async {
    if (widget.isAnimation || widget.smallike) {
      await controller.forward();
      await controller.reverse();
      await Future.delayed(Duration(milliseconds: 200));

      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}
