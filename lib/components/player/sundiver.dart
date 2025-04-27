import 'dart:math' as math;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:red_ocelot/components/alive.dart';
import 'package:red_ocelot/components/flame_shaders/sampler_camera.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/components/player/laser.dart';
import 'package:red_ocelot/components/samplers/laser.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/red_ocelot_world.dart';

class SunDiver extends BodyComponent<RedOcelotGame>
    with ContactCallbacks, KeyboardHandler, Alive {
  SunDiver({
    Vector2? startPos,
    Vector2? size,
    super.priority = 2,
    int? hitPoints,
    super.key,
  }) : super() {
    // set the size of the ship
    this.size = size ?? Vector2.all(shipSize);
    // set the position of the ship
    this.startPos = startPos ?? Vector2.all(RedOcelotMap.size / 2);
    this.hitPoints = hitPoints ?? 50;
  }

  static final TextPaint textRenderer = TextPaint(
    style: const TextStyle(color: Colors.white70, fontSize: 8 * gameUnit),
  );
  late final Vector2 startPos;
  late final Vector2 size;
  static const double maxSpeed = RedOcelotMap.size * shipMaxVelocity * 0.1;
  static double speed = 0;
  static const double _shipRotationSpeed = shipRotationSpeed;
  final Vector2 velocity = Vector2.zero();
  late final TextComponent positionText;
  late final Vector2 textPosition;
  late final maxPosition = Vector2.all(RedOcelotMap.size / 2 - size.x);
  late final minPosition = -maxPosition;
  Color currentColor = Colors.black;
  double colorProgress = 0.0;
  bool flashRed = false;
  final shipColor =
      Paint()
        ..colorFilter = ColorFilter.mode(
          const Color.fromARGB(255, 189, 4, 4),
          BlendMode.srcIn, // ✅
        );
  void triggerFlash() {
    flashRed = true;
  }

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
  Future<void> onLoad() async {
    // debugMode = true;
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
      paint: shipColor,
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

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void _shoot() {
    final laser = Laser(startPos: position, direction: body.angle - pi / 2);
    world.add(laser);
  }

  void reset() {
    lifePoints = hitPoints;
    body.setTransform(startPos, 0);
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0;
    _shotSpawner.stop();
    _shotSpawner.reset();
    if (isRemoved) {
      game.add(this);
    }
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
      triggerFlash();
      _accelerate(dt);
    }
    if (_decelerating) {
      _decelerate(dt);
    }

    _repulse();

    position.clamp(minPosition, maxPosition);
    final angle = body.angle;

    final offset = Vector2(
      -sin(angle) * (size.y / 8),
      cos(angle) * (size.y / 8),
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
                  getRandomVector() *
                  0.15 *
                  max(body.linearVelocity.length, 0.5),
              speed:
                  getRandomVector() *
                  0.20 *
                  max(body.linearVelocity.length, 0.5),
              child: CircleParticle(
                radius: size.x,
                paint: Paint()..color = Colors.orange.withAlpha(128),
              ),
            ),
      ),
    )..angle = body.angle;

    game.add(particle); // Don't add it to the SunDiver (a Forge2D component)
    if (flashRed) {
      colorProgress += dt; // Increase progress
      if (colorProgress >= 1.0) {
        colorProgress = 1.0;
        flashRed = false; // Flash done
      }
    } else if (colorProgress > 0) {
      colorProgress -= dt; // Fade back to black
      if (colorProgress <= 0) {
        colorProgress = 0;
      }
    }

    // Update the current color
    currentColor =
        Color.lerp(
          const Color.fromARGB(255, 7, 60, 15),
          const Color(0xFFBD0404), // Red
          colorProgress.clamp(0.0, 1.0),
        )!;

    shipColor.colorFilter = ColorFilter.mode(currentColor, BlendMode.srcIn);
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
        _decelerating = !_accelerating;
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

  void reactToJoystickInput(Vector2 input) {
    if (input.length < 0.2) {
      // No input → no rotation or movement
      _decelerating = true;
      return;
    }
    _decelerating = false;
    final desiredAngle = math.atan2(input.x, -input.y);
    final currentAngle = body.angle;

    double angleDifference = desiredAngle - currentAngle;

    // Normalize angle to range [-π, π]
    while (angleDifference > pi) {
      angleDifference -= 2 * pi;
    }
    while (angleDifference < -pi) {
      angleDifference += 2 * pi;
    }

    // Apply small rotation toward desiredAngle
    const rotationStrength = 0.05; // Tweak this
    final smoothedRotation = angleDifference * 0.01; // Easing toward target
    body.applyAngularImpulse(smoothedRotation * rotationStrength);

    // Apply forward thrust in current facing direction
    const thrustStrength = 1.0; // Tweak this

    if (body.linearVelocity.length > maxSpeed) {
      body.linearVelocity.scaleTo(maxSpeed);
    }

    body.applyForce(
      Vector2(cos(desiredAngle - pi / 2), sin(desiredAngle - pi / 2)) *
          thrustStrength *
          input.length,
    );
  }

  void _rotateLeft(double dt) {
    body.applyAngularImpulse(-_shipRotationSpeed * dt);
  }

  void _rotateRight(double dt) {
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

  @override
  void beginContact(Object other, Contact contact) {
    if (kDebugMode) {
      print('begin contact with $other');
    }
    if (other is MovingClusterObject) {
      if (game.isMounted) {
        game.gameOver();
      }
    }
  }

  void _decelerate(double dt) {
    final delta = (shipDeceleration * maxSpeed) * dt;
    body.applyLinearImpulse(body.linearVelocity * -delta);

    speed = body.linearVelocity.length;

    if (speed > maxSpeed) {
      // this shouldn't be modified directly ....so be it?
      body.linearVelocity.scaleTo(maxSpeed);
      return;
    }
  }
}
