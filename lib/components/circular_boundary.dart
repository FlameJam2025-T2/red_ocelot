import 'dart:math' as math;

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:red_ocelot/config/world_parameters.dart';

class CircularBoundary extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 center;
  double radius;
  final int segments = 50;
  late FixtureDef _fixture;

  CircularBoundary(this.center, this.radius);

  @override
  Body createBody() {
    body = world.createBody(BodyDef()..position = center);

    for (int i = 0; i < segments; i++) {
      final angle1 = 2 * math.pi * i / segments;
      final angle2 = 2 * math.pi * (i + 1) / segments;

      final v1 = Vector2(math.cos(angle1), math.sin(angle1)) * radius;
      final v2 = Vector2(math.cos(angle2), math.sin(angle2)) * radius;

      final shape = EdgeShape()..set(v1, v2);

      _fixture =
          FixtureDef(shape)
            ..userData = this
            ..filter.categoryBits = CollisionType.boundary;

      body.createFixture(_fixture);
    }

    return body;
  }

  void reset() {
    body.transform.p.setFrom(center);
    _fixture.shape.radius = radius;
  }
}
