import 'package:flutter/material.dart';

class MyAnimations {
  static Widget transformFromTop50({required Widget child, Tween<Offset>? transformTween}) {
    transformTween = Tween(begin: Offset(0, -100), end: Offset(0, 0));
    return TweenAnimationBuilder(
      tween: transformTween,
      duration: Duration(milliseconds: 300),
      builder: (context, Offset tween, child) => Transform.translate(offset: tween, child: child),
      child: child,
    );
  }

  static Widget transformRightToLeft({required Widget child, Tween<Offset>? transformTween, Duration? duration}) {
    transformTween = transformTween ?? Tween(begin: Offset(1500, 0), end: Offset(0, 0));
    return TweenAnimationBuilder(
      tween: transformTween,
      duration: duration ?? Duration(milliseconds: 1000),
      builder: (context, Offset tween, child) => Transform.translate(offset: tween, child: child),
      child: child,
    );
  }

  static Widget fadeOut({required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 150),
      builder: (context, double tween, child) => Transform.scale(scale: tween, child: child),
      child: child,
    );
  }

  static Widget animatedSwicherTransition({required Duration duration}) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
    );
  }
}
