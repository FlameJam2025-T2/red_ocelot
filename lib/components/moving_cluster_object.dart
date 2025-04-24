import 'dart:math' as math;

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/circular_boundary.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/utils/sprite_utils.dart';

class MovingClusterObject extends BodyComponent with ContactCallbacks {
  final Vector2 startPos;
  final Color color;
  double radius = 10 * gameUnit;
  double initialVelocity = 10 * gameUnit;
  String? letter;
  double changeDirectionTimer = 0;
  double changeInterval = 2.0; // seconds
  late TextPainter textPainter;
  SpriteName spriteName;

  MovingClusterObject(
    this.startPos, {
    required this.spriteName,
    this.color = Colors.orange,
  });

  @override
  Future<void> onLoad() {
    paint = Paint()..color = color;
    textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * .75, // scale with size
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    AnimatedSprite anim =
        AnimatedSprite(spriteName: spriteName)
          ..size = Vector2(radius * 1.5, radius * 1.5)
          ..position = Vector2(-radius * .75, -radius * .75);
    add(anim);
    return super.onLoad();
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius.toDouble();
    final fixtureDef =
        FixtureDef(shape)
          ..restitution = 1.0
          ..density = 1.0
          ..friction = 0.0
          ..userData = this;

    final bodyDef =
        BodyDef()
          ..type = BodyType.dynamic
          ..position = startPos
          ..linearVelocity = _randomVelocity();

    final body = world.createBody(bodyDef);
    body.createFixture(fixtureDef);
    return body;
  }

  Vector2 _randomVelocity() {
    return (Vector2.random() - Vector2.random()).normalized() * initialVelocity;
  }

  @override
  void update(double dt) {
    super.update(dt);

    changeDirectionTimer += dt;
    if (changeDirectionTimer >= changeInterval) {
      // Pick a new direction
      body.linearVelocity = _randomVelocity();
      changeDirectionTimer = math.Random().nextDouble() * changeInterval / 2;
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is CircularBoundary) {
      print("Collision with CircularBoundary");
    }
  }

  @override
  void render(Canvas canvas) {
    // super.render(canvas);

    // canvas.drawCircle(Vector2.zero().toOffset(), radius.toDouble(), paint);

    // final offset = Offset(-textPainter.width / 2, -textPainter.height / 2);

    // textPainter.paint(canvas, offset);
  }
}
