import 'dart:math' as math;

import 'package:flame_forge2d/flame_forge2d.dart';

class CircularBoundary extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 center;
  final double radius;
  final int segments = 50;

  CircularBoundary(this.center, this.radius);

  @override
  Body createBody() {
    final bodyDef = BodyDef()..position = center;
    final body = world.createBody(bodyDef);

    for (int i = 0; i < segments; i++) {
      final angle1 = 2 * math.pi * i / segments;
      final angle2 = 2 * math.pi * (i + 1) / segments;

      final v1 = Vector2(math.cos(angle1), math.sin(angle1)) * radius;
      final v2 = Vector2(math.cos(angle2), math.sin(angle2)) * radius;

      final shape = EdgeShape()..set(v1, v2);

      final fixtureDef = FixtureDef(shape)
        ..userData = this; // 👈 this links the fixture to the component

      body.createFixture(fixtureDef);
    }

    return body;
  }
}
