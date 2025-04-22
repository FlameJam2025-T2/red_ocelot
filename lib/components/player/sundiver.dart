import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelet_game.dart';
import 'package:red_ocelot/red_ocelet_world.dart';

class SunDiver extends BodyComponent<RedOceletGame>
    with ContactCallbacks, KeyboardHandler {
  SunDiver({
    Vector2? startPos,
    Vector2? shipSize,
    super.priority = 2,
    super.key,
  }) : super() {
    // set the size of the ship
    size = shipSize ?? Vector2.all(5);
    // set the position of the ship
    this.startPos = startPos ?? Vector2.all(RedOcelotMap.size / 2);
  }

  static final TextPaint textRenderer = TextPaint(
    style: const TextStyle(color: Colors.white70, fontSize: 12),
  );
  late final Vector2 startPos;
  late final Vector2 size;
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
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      type: BodyType.dynamic,
      position: startPos,
      linearDamping: 0.0,
      angularDamping: shipAngularDamping,
    );

    final vertices = [
      Vector2(0, -size.y / 2),
      Vector2(-size.x / 2, size.y / 2),
      Vector2(size.x / 2, size.y / 2),
    ];
    // create a triangle (for now) shape for the ship
    final fixtureDef = FixtureDef(
      PolygonShape()..set(vertices),
      userData: this,
      restitution: 0.2,
      density: shipDensity,
      friction: 0.0,
    );

    final sprite = Sprite(game.images.fromCache('sundiver.png'));

    final ship = SpriteComponent(
      sprite: sprite,
      size: size,
      anchor: Anchor.center,
      angle: 0,
      nativeAngle: 0,
    );
    add(ship);

    positionText = TextComponent(
      textRenderer: textRenderer,
      scale: Vector2.all(0.25),
      position: (size / 2)..y = size.y / 2 + (size.y / 3),
      anchor: Anchor.center,
    );
    add(positionText);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
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
    //final deltaPosition = velocity;
    //position.add(deltaPosition);
    position.clamp(minPosition, maxPosition);
    positionText.text =
        '(x: ${position.x.toInt()}, y: ${position.y.toInt()}, 𝜃: ${angle.toStringAsPrecision(2)}, s: ${speed.toStringAsPrecision(2)}, vx: ${velocity.x.toStringAsPrecision(2)}, vy: ${velocity.y.toStringAsPrecision(2)})';
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
    // angle -= _shipRotationSpeed * dt;
    // angle = angle % (2 * pi);

    body.applyAngularImpulse(-_shipRotationSpeed * dt);
  }

  void _rotateRight(double dt) {
    // angle += _shipRotationSpeed * dt;
    // angle = angle % (2 * pi);

    body.applyAngularImpulse(_shipRotationSpeed * dt);
  }

  void _accelerate(double dt) {
    speed = body.linearVelocity.length;
    if (speed > maxSpeed) {
      // this shouldn't be modified directly ....so be it?
      body.linearVelocity.scaleTo(maxSpeed);
      return;
    }

    final delta = (shipAcceleration * maxSpeed) * dt;
    body.applyLinearImpulse(
      Vector2(cos(angle - pi / 2) * delta, sin(angle - pi / 2) * delta),
    );
  }

  void _decelerate(double dt) {
    speed = body.linearVelocity.length;

    if (speed > maxSpeed) {
      // this shouldn't be modified directly ....so be it?
      body.linearVelocity.scaleTo(maxSpeed);
      return;
    }

    final delta = (shipDeceleration * maxSpeed) * dt;
    body.applyLinearImpulse(
      Vector2(cos(angle - pi / 2) * -delta, sin(angle - pi / 2) * -delta),
    );
  }
}
