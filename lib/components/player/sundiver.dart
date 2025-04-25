import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:red_ocelot/components/flame_shaders/sampler_camera.dart';
import 'package:red_ocelot/components/player/laser.dart';
import 'package:red_ocelot/components/samplers/laser.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/red_ocelot_world.dart';

class SunDiver extends BodyComponent<RedOcelotGame>
    with ContactCallbacks, KeyboardHandler {
  SunDiver({Vector2? startPos, Vector2? size, super.priority = 2, super.key})
    : super() {
    // set the size of the ship
    this.size = size ?? Vector2.all(shipSize);
    // set the position of the ship
    this.startPos = startPos ?? Vector2.all(RedOcelotMap.size / 2);
  }

  static final TextPaint textRenderer = TextPaint(
    style: const TextStyle(color: Colors.white70, fontSize: 8 * gameUnit),
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

  late final LaserSamplerOwner _laserShader;
  late final SamplerCamera _laserCamera;

  bool _rotatingLeft = false;
  bool _rotatingRight = false;
  bool _accelerating = false;
  bool _decelerating = false;
  bool _shooting = false;

  late final Timer _shotSpawner;
  final _random = Random();

  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 200;
  }

  @override
  void onMount() {
    // TODO: implement onMount

    super.onMount();
  }

  @override
  Future<void> onLoad() async {
    debugMode = true;
    await super.onLoad();
  }

  @override
  Body createBody() {
    _shotSpawner = Timer(
      Laser.cooldown,
      onTick: _shoot,
      repeat: true,
      autoStart: false,
    );

    renderBody = false;
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
    final fixtureDef =
        FixtureDef(
            PolygonShape()..set(vertices),
            isSensor: false,
            userData: this,
            restitution: 0.2,
            density: shipDensity,
            friction: 0.0,
          )
          ..filter.categoryBits = CollisionType.sundiver
          ..filter.maskBits = CollisionType.monster | CollisionType.laser;

    final sprite = Sprite(game.images.fromCache('sundiver.png'));

    final ship = SpriteComponent(
      sprite: sprite,
      size: size,
      anchor: Anchor.center,
      angle: 0,
      nativeAngle: 0,
    );
    add(ship);

    _laserShader = LaserSamplerOwner(game.laserShader, game);
    _laserCamera = SamplerCamera.withFixedResolution(
      samplerOwner: _laserShader,
      width: game.viewportResolution.x,
      height: game.viewportResolution.y,
      world: world,
      pixelRatio: 1.0,
    );

    //game.add(_laserCamera);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void _shoot() {
    final laser = Laser(startPos: position, direction: body.angle - pi / 2);
    world.add(laser);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _laserCamera.update(dt);
    _shotSpawner.update(dt);
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
    _repulse();
    position.clamp(minPosition, maxPosition);
    // positionText.text =
    //     '(x: ${position.x.toInt()}, y: ${position.y.toInt()}, 𝜃: ${angle.toStringAsPrecision(2)}, s: ${speed.toStringAsPrecision(2)}, vx: ${body.linearVelocity.x.toStringAsPrecision(2)}, vy: ${body.linearVelocity.y.toStringAsPrecision(2)})';
    final angle = body.angle;
    final offset = Vector2(
      sin(angle) * (size.y / 2),
      -cos(angle) * (size.y / 2),
    );

    final worldPos = body.position - offset;
    final screenPos = game.worldToScreen(worldPos);

    final particle = ParticleSystemComponent(
      position: screenPos,
      particle: Particle.generate(
        count: 50,
        lifespan: 0.4,
        generator:
            (i) => AcceleratedParticle(
              acceleration:
                  getRandomVector() * 0.15 * max(body.linearVelocity.length, 1),
              speed:
                  getRandomVector() * 0.2 * max(body.linearVelocity.length, 1),
              child: CircleParticle(
                radius: size.x,
                paint: Paint()..color = Colors.orange.withOpacity(0.8),
              ),
            ),
      ),
    )..angle = body.angle;

    game.add(particle); // Don't add it to the SunDiver (a Forge2D component)
  }

  /// add repulsion to world boundaries so as the ship approaches the boundaries
  /// it will experience a force pushing it back to the center of the screen
  void _repulse() {
    const double radius =
        100 *
        gameUnit; // how close to the edge before the force is gradually applied
    const double decay = 0.2; // how much the force decays per unit distance
    final currentPosition = body.position;

    final x = currentPosition.x;
    final y = currentPosition.y;
    final dx = (x > maxPosition.x - radius) ? maxPosition.x - x : 0;
    final dy = (y > maxPosition.y - radius) ? maxPosition.y - y : 0;
    final ax = (x < minPosition.x + radius) ? minPosition.x - x : 0;
    final ay = (y < minPosition.y + radius) ? minPosition.y - y : 0;
    final forceX = (dx + ax) * 1 / radius / decay;
    final forceY = (dy + ay) * 1 / radius / decay;
    final force = Vector2(forceX, forceY);
    if (force.length > 0) {
      body.applyForce(force);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent || event is KeyRepeatEvent;

    final bool handled;

    // left / right key rotate the ship
    // up accellerates the ship, and down decellerates it (no reverse)
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_rotatingLeft != isKeyDown) {
        _rotatingLeft = isKeyDown;
      }
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_rotatingRight != isKeyDown) {
        _rotatingRight = isKeyDown;
      }
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      // accelerate the ship
      if (_accelerating != isKeyDown) {
        _accelerating = isKeyDown;
      }
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // decelerate the ship
      if (_decelerating != isKeyDown) {
        _decelerating = isKeyDown;
      }
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      // shoot a bullet

      if (_shooting != isKeyDown) {
        _shooting = isKeyDown;
        if (_shooting) {
          _shotSpawner.start();
        } else {
          _shotSpawner.stop();
        }
      }
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

  void startShooting() {
    _shooting = true;
    _shotSpawner.start();
  }

  void stopShooting() {
    _shooting = false;
    _shotSpawner.stop();
  }

  void handlJoystickInput(Vector2 input) {
    if (input.x < -0.4) {
      _rotatingLeft = true;
      _rotatingRight = false;
    } else if (input.x > 0.4) {
      _rotatingLeft = false;
      _rotatingRight = true;
    } else {
      _rotatingLeft = false;
      _rotatingRight = false;
    }

    if (input.y < -0.3) {
      _accelerating = true;
      _decelerating = false;
    } else if (input.y > 0.3) {
      _accelerating = false;
      _decelerating = true;
    } else {
      _accelerating = false;
      _decelerating = false;
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
    final delta = (shipAcceleration * maxSpeed) * dt;
    body.applyLinearImpulse(
      Vector2(cos(angle - pi / 2) * delta, sin(angle - pi / 2) * delta),
    );

    speed = body.linearVelocity.length;

    if (speed > maxSpeed) {
      // this shouldn't be modified directly ....so be it?
      body.linearVelocity.scaleTo(maxSpeed);
      return;
    }
  }

  void _decelerate(double dt) {
    final delta = (shipDeceleration * maxSpeed) * dt;
    body.applyLinearImpulse(
      Vector2(cos(angle - pi / 2) * -delta, sin(angle - pi / 2) * -delta),
    );

    speed = body.linearVelocity.length;

    if (speed > maxSpeed) {
      // this shouldn't be modified directly ....so be it?
      body.linearVelocity.scaleTo(maxSpeed);
      return;
    }
  }
}
