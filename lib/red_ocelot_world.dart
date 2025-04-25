import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/cluster.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

abstract mixin class WorldMap {
  void reset();
}

class RedOcelotWorld extends Forge2DWorld with HasGameReference<RedOcelotGame> {
  RedOcelotWorld({required WorldMap map}) : super(gravity: Vector2.zero()) {
    _map = map;
  }
  final paint = Paint()..color = Colors.black;
  late WorldMap _map;

  WorldMap get map => _map;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_map as Component);
  }

  void reset() {
    _map.reset();
  }
}

class RedOcelotMap extends Component
    with WorldMap, HasGameReference<RedOcelotGame> {
  static const double size = mapSize;
  static final Rectangle bounds = Rectangle.fromLTRB(-size, -size, size, size);
  static Random _rng = Random();

  final int? seed;
  late Cluster cluster;

  RedOcelotMap({this.seed}) : super(priority: 0) {
    _rng = seed != null ? Random(seed) : Random();
  }

  static Random get rng => _rng;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  Future<void> onMount() async {
    cluster = Cluster(count: 40, radius: 250 * gameUnit, rng: _rng)
      ..position = Vector2(500 * gameUnit, 300 * gameUnit);
    await add(cluster);
  }

  @override
  void reset() {
    cluster.reset();
  }

  static Vector2 generateCoordinates() {
    return Vector2.random()
      ..scale(2 * size)
      ..sub(Vector2.all(size));
  }
}
