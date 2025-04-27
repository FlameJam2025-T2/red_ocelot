import 'dart:math' as math;

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/alive.dart';
import 'package:red_ocelot/components/cluster.dart';
import 'package:red_ocelot/components/health_bar.dart';
import 'package:red_ocelot/components/player/laser.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/util/sprite_utils.dart';

class MovingClusterObject extends BodyComponent<RedOcelotGame>
    with ContactCallbacks, Alive {
  final Vector2 startPos;
  final Color color;
  double radius = 10 * gameUnit;
  double initialVelocity = 10 * gameUnit;
  double changeDirectionTimer = 0;
  double changeInterval = 2.0; // seconds
  SpriteName spriteName;
  Cluster cluster;

  MovingClusterObject(
    this.startPos, {
    required this.spriteName,
    required this.cluster,
    required hitPoints,
    this.color = Colors.orange,
  }) : super() {
    this.hitPoints = hitPoints;
    lifePoints = hitPoints;
  }

  @override
  Future<void> onLoad() {
    paint = Paint()..color = color;

    AnimatedSprite anim =
        AnimatedSprite(spriteName: spriteName)
          ..size = Vector2(radius * 1.5, radius * 1.5)
          ..position = Vector2(-radius * .75, -radius * .75);
    add(anim);
    add(HealthBar(parentObject: this)..position = Vector2(0, 0));
    return super.onLoad();
  }

  void reset() {
    lifePoints = hitPoints;
    changeDirectionTimer = 0;
    body.linearVelocity = _randomVelocity();
    body.setTransform(startPos, 0);
    if (isRemoved) {
      game.add(this);
    }
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius.toDouble();
    final fixtureDef =
        FixtureDef(shape, isSensor: false)
          ..restitution = 1.0
          ..density = 1.0
          ..friction = 0.0
          ..userData = this
          ..filter.categoryBits = CollisionType.monster;

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
    if (other is Laser) {
      lifePoints -= Laser.damage;
      if (lifePoints <= 0) {
        game.incrementScore(points: hitPoints);
        game.clusterMap.reduceClusterObject(cluster);
        // if (game.clusterMap.numberClusterObjects[clusterIndex] <= 0) {
        //   game.clusterMap.clusters[clusterIndex].removeFromParent();
        // }

        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // super.render(canvas);

    // canvas.drawCircle(Vector2.zero().toOffset(), radius.toDouble(), paint);
  }
}
