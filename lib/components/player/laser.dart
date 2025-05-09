import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/components/weapon.dart';

import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/config/world_parameters.dart';

class Laser extends BodyComponent<RedOcelotGame> with Weapon, ContactCallbacks {
  Laser({
    required this.startPos,
    required double direction,
    Vector2? size,
    this.decay = 0.5,
    this.lifetime = 0.5,
    super.priority = 1,
    super.key,
  }) : super() {
    // set the size of the laser
    this.size = size ?? Vector2.all(2 * gameUnit);
    this.direction = Vector2(cos(direction), sin(direction));
  }
  static const double cooldown = 0.1;
  static const int damage = 2;
  late final Vector2 startPos;
  late final Vector2 size;
  late final Vector2 direction;
  late final double decay;
  late final double lifetime;
  late final Timer _destroyTimer;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      type: BodyType.kinematic,
      position: startPos,
      linearDamping: 0.0,
      angularDamping: 0.0,
      fixedRotation: true,
      bullet: true,
    );
    final vertices = [
      Vector2(0, -size.y / 2),
      Vector2(-size.x / 2, size.y / 2),
      Vector2(size.x / 2, size.y / 2),
    ];

    final fixtureDef = FixtureDef(
      PolygonShape()..set(vertices),
      friction: 0,
      restitution: 0,
      density: 0,
      isSensor: true,
      userData: this,
    );
    final body =
        world.createBody(bodyDef)
          ..createFixture(fixtureDef)
          ..linearVelocity = direction * 100;
    _destroyTimer = Timer(
      lifetime,
      onTick: () {
        removeFromParent();
      },
    );
    renderBody = false;
    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is MovingClusterObject) {
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _destroyTimer.update(dt);
  }
}
