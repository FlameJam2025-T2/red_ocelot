import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/cluster.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

// addd sounds
// laser,
// accel
// crash
// explosion
// hit

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
  static final Rectangle bounds = Rectangle.fromCenter(
    center: Vector2.zero(),
    size: Vector2(size, size),
  );
  static Random _rng = Random();
  final double clusterRadius = 250 * gameUnit;

  final int? seed;
  final List<Cluster> clusters = [];
  final Map<Cluster, Vector2> clusterPositions = {};
  late Map<Cluster, int> numberClusterObjects = {};

  RedOcelotMap({this.seed}) : super(priority: 0) {
    _rng = seed != null ? Random(seed) : Random();
  }

  static Random get rng => _rng;

  void reduceClusterObject(Cluster cluster) {
    if (numberClusterObjects[cluster] != null) {
      numberClusterObjects[cluster] = numberClusterObjects[cluster]! - 1;
    } else {
      throw Exception("Cluster not found in numberClusterObjects");
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  double gaussianRandom({double mean = 0, double stdDev = 1}) {
    final u1 = Random().nextDouble();
    final u2 = Random().nextDouble();
    final z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
    return z0 * stdDev + mean;
  }

  Vector2 generateCoordinates(List<Vector2> existing) {
    final double worldMin = -mapSize / 2;
    final double worldMax = mapSize / 2;

    final double minDistance = clusterRadius * 2;
    const int maxTries = 1000;
    for (int attempt = 0; attempt < maxTries; attempt++) {
      final x =
          _rng.nextDouble() * (worldMax - worldMin - 2 * clusterRadius) +
          worldMin +
          clusterRadius;
      final y =
          _rng.nextDouble() * (worldMax - worldMin - 2 * clusterRadius) +
          worldMin +
          clusterRadius;
      final candidate = Vector2(x, y);

      bool overlaps = existing.any(
        (c) => c.distanceToSquared(candidate) < minDistance * minDistance,
      );

      if (!overlaps) return candidate;
    }

    throw Exception(
      "Could not place non-overlapping cluster after $maxTries attempts",
    );
  }

  Future<void> populateClusters() async {
    for (int i = 0; i < clusterCount; i++) {
      final coordinates = generateCoordinates(
        clusterPositions.values.toList(growable: false),
      );
      final count = max(1, gaussianRandom(mean: 30, stdDev: 5).round());
      final cluster = Cluster(
        clusterIndex: i,
        count: count,
        radius: clusterRadius,
      )..position = coordinates;

      clusters.add(cluster);
      numberClusterObjects[cluster] = count;
      clusterPositions[cluster] = coordinates;
    }
    await addAll(clusters);
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    await populateClusters();
  }

  @override
  void reset() {
    for (Cluster cluster in clusters) {
      cluster.reset();
    }
    List<Cluster> removeItems = children.whereType<Cluster>().toList();
    for (Cluster cluster in removeItems) {
      cluster.removeFromParent();
    }
    clusters.clear();
    numberClusterObjects.clear();
    clusterPositions.clear();
    populateClusters();
  }
}
