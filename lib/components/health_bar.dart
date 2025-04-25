import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';

class HealthBar extends PositionComponent {
  final MovingClusterObject parentObject;

  HealthBar({required this.parentObject}) : super(anchor: Anchor.center);

  @override
  final double width = 4 * gameUnit;
  @override
  late double height;
  late Paint paint;
  late Paint bgPaint;
  Color barColor = Colors.green;

  @override
  FutureOr<void> onLoad() {
    height = parentObject.radius * 1.5;
    position = Vector2(
      parentObject.radius / 2 + 5 * gameUnit,
      -parentObject.radius * 0.75,
    );

    paint = Paint()..color = barColor;
    bgPaint = Paint()..color = const Color.fromARGB(255, 174, 171, 171);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final double percent = parentObject.lifePoints / parentObject.hitPoints;

    // Interpolate from green to red

    if (percent > 0.7) {
      barColor = Colors.green;
    } else if (percent > 0.4) {
      barColor = Colors.yellow;
    } else if (percent > 0.2) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Draw foreground bar
    canvas.drawRect(
      Rect.fromLTWH(0, height * (1 - percent), width, height * percent),
      paint..color = barColor,
    );
  }
}
