import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelet_world.dart';

class SunDiver<T extends FlameGame> extends SpriteComponent
    with HasGameReference<T>, CollisionCallbacks, KeyboardHandler {
  SunDiver({super.position, Vector2? size, super.priority = 2, super.key})
    : super(
        size: size ?? Vector2.all(50),
        anchor: Anchor.center,
        angle: 0,
        nativeAngle: 0,
      );

  static final TextPaint textRenderer = TextPaint(
    style: const TextStyle(color: Colors.white70, fontSize: 12),
  );

  static const double maxSpeed = RedOcelotMap.size * shipMaxVelocity;
  static double speed = 0;
  static const double _shipRotationSpeed = shipRotationSpeed;
  final Vector2 velocity = Vector2.zero();
  late final TextComponent positionText;
  late final Vector2 textPosition;
  late final maxPosition = Vector2.all(RedOcelotMap.size - size.x / 2);
  late final minPosition = -maxPosition;

  bool _rotatingLeft = false;
  bool _rotatingRight = false;
  bool _accelerating = false;
  bool _decelerating = false;

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('sundiver.png');
    await super.onLoad();
    positionText = TextComponent(
      textRenderer: textRenderer,
      position: (size / 2)..y = size.y / 2 + 30,
      anchor: Anchor.center,
    );
    add(positionText);
    // define the hitbox as the shape of the sprite (a triangle)
    final vertices = [
      Vector2(0, -size.y / 2),
      Vector2(-size.x / 2, size.y / 2),
      Vector2(size.x / 2, size.y / 2),
    ];
    add(PolygonHitbox(vertices));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_rotatingLeft) {
      _rotateLeft(dt);
    }
    if (_rotatingRight) {
      _rotateRight(dt);
    }
    if (_accelerating) {
      _accelerate(dt);
    }
    if (_decelerating) {
      _decelerate(dt);
    }
    final deltaPosition = velocity;
    position.add(deltaPosition);
    position.clamp(minPosition, maxPosition);
    positionText.text =
        '(x: ${x.toInt()}, y: ${y.toInt()}, 𝜃: ${angle.toStringAsPrecision(2)}, s: ${speed.toStringAsPrecision(2)}, vx: ${velocity.x.toStringAsPrecision(2)}, vy: ${velocity.y.toStringAsPrecision(2)})';
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent || event is KeyRepeatEvent;

    final bool handled;

    // left / right key rotate the ship
    // up accellerates the ship, and down decellerates it (no reverse)
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _rotatingLeft = isKeyDown;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _rotatingRight = isKeyDown;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      // accelerate the ship
      _accelerating = isKeyDown;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // decelerate the ship
      _decelerating = isKeyDown;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      // shoot a bullet
      handled = true;
    } else {
      handled = false;
    }

    if (handled) {
      return false;
    } else {
      return super.onKeyEvent(event, keysPressed);
    }
  }

  void _rotateLeft(double dt) {
    angle -= _shipRotationSpeed * dt;
    angle = angle % (2 * pi);
  }

  void _rotateRight(double dt) {
    angle += _shipRotationSpeed * dt;
    angle = angle % (2 * pi);
  }

  void _accelerate(double dt) {
    final delta = (shipAcceleration * maxSpeed) * dt;
    velocity.add(
      Vector2(cos(angle - pi / 2) * delta, sin(angle - pi / 2) * delta),
    );

    speed = velocity.length;
    if (speed > maxSpeed) {
      speed = maxSpeed;
      velocity.scaleTo(maxSpeed);
    }
  }

  void _decelerate(double dt) {
    final delta = (shipDeceleration * maxSpeed) * dt;
    velocity.add(
      Vector2(cos(angle - pi / 2) * -delta, sin(angle - pi / 2) * -delta),
    );

    speed = velocity.length;
    if (speed > maxSpeed) {
      speed = maxSpeed;
      velocity.scaleTo(maxSpeed);
    }
  }
}
