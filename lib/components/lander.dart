import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:red_ocelot/red_ocelet_game.dart';

class Lander extends PositionComponent
    with KeyboardHandler, HasGameReference<RedOceletGame> {
  final double gravity = 200; // pixels per second squared
  final double thrustPower = 210;
  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    anchor = Anchor.topCenter;
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void update(double dt) {
    velocity.y += gravity * dt;
    if (velocity.y > 300) {
      velocity.y = 300;
    }
    if (velocity.y < -300) {
      velocity.y = -300;
    }
    if (velocity.x > 75) {
      velocity.x = 75;
    }
    if (velocity.x < -75) {
      velocity.x = -75;
    }

    position += velocity * dt;

    // Prevent falling off screen
    if (position.y > 600 - 80) {
      position.y = 600 - 80;
      velocity = Vector2.zero();
    }
    if (position.y < 0) {
      position.y = 0;
      velocity.y = 0;
    }
  }

  @override
  void onMount() {
    size = Vector2(20, 40);
    super.onMount();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      velocity.y -= thrustPower;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      velocity.x -= thrustPower / 4;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      velocity.x += thrustPower / 4;
    }
    print("velocity: $velocity");
    return true;
  }
}
