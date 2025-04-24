import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/cluster.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

class RedocelotWorld extends Forge2DWorld with HasGameReference<RedocelotGame> {
  RedocelotWorld() : super(gravity: Vector2.zero());
  final paint = Paint()..color = Colors.black;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }
}

class RedOcelotMap extends Component with HasGameRef<RedOceletGame> {
  static const double size = mapSize;
  static final Rectangle bounds = Rectangle.fromLTRB(-size, -size, size, size);
  // ignore: unused_field
  static Random _rng = Random();

  final int? seed;
  late Cluster cluster;

  RedOcelotMap({this.seed}) : super(priority: 0) {
    _rng = seed != null ? Random(seed) : Random();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    cluster = Cluster(count: 40, radius: 250 * gameUnit)
      ..position = Vector2(500 * gameUnit, 300 * gameUnit);
    await add(cluster);
  }

  static Vector2 generateCoordinates() {
    return Vector2.random()
      ..scale(2 * size)
      ..sub(Vector2.all(size));
  }
}
