import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/cluster.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

class RedocelotWorld extends Forge2DWorld with HasGameReference<RedOcelotGame> {
  RedocelotWorld() : super(gravity: Vector2.zero());
  final paint = Paint()..color = Colors.black;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }
}

class RedOcelotMap extends Component with HasGameReference<RedOcelotGame> {
  static const double size = mapSize;
  static final Rectangle bounds = Rectangle.fromLTRB(-size, -size, size, size);
  static Random _rng = Random();

  final int? seed;
  late List<Cluster> clusters;
  late List<int> numberClusterObjects = [];

  RedOcelotMap({this.seed}) : super(priority: 0) {
    _rng = seed != null ? Random(seed) : Random();
  }

  static Random get rng => _rng;

  void reduceClusterObject({int clusterIndex = 0}) {
    numberClusterObjects[clusterIndex]--;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final double worldMin = -5000 * gameUnit;
    final double worldMax = 5000 * gameUnit;
    final double clusterRadius = 250 * gameUnit;
    final double minDistance = clusterRadius * 2;

    double gaussianRandom({double mean = 0, double stdDev = 1}) {
      final u1 = Random().nextDouble();
      final u2 = Random().nextDouble();
      final z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
      return z0 * stdDev + mean;
    }

    Vector2 generateCoordinates(List<Vector2> existing) {
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

    clusters = [];
    final positions = <Vector2>[];

    for (int i = 0; i < 10; i++) {
      final coordinates = generateCoordinates(positions);
      final count = max(1, gaussianRandom(mean: 35, stdDev: 5).round());
      numberClusterObjects.add(count);
      final cluster = Cluster(
        clusterIndex: i,
        count: count,
        radius: clusterRadius,
      )..position = coordinates;

      clusters.add(cluster);
      positions.add(coordinates);
    }

    await addAll(clusters);
  }
}
