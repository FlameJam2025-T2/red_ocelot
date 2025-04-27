import 'dart:math';

import 'package:flame/components.dart';
import 'package:red_ocelot/components/circular_boundary.dart';
import 'package:red_ocelot/components/monster_a.dart';
import 'package:red_ocelot/components/monster_b.dart';
import 'package:red_ocelot/components/monster_c.dart';
import 'package:red_ocelot/components/monster_d.dart';
import 'package:red_ocelot/components/monster_e.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/components/ufo.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

class Cluster extends PositionComponent with HasGameReference<RedOcelotGame> {
  final int count;
  double standardDeviation = 4 * gameUnit;
  double radius;
  final double percentageUFO = 0.2;
  final double percentageMonster1 = 0.5;

  int clusterIndex;
  late final CircularBoundary circularBoundary;
  late final Vector2 _center;
  final List<Map<String, dynamic>> _enemyBuilders = [];
  final List<MovingClusterObject> _enemies = [];

  Cluster({
    required this.clusterIndex,
    required this.count,
    required this.radius,
  });

  @override
  Future<void> onLoad() async {
    _center = position + size / 2; // world space center

    game.world.add(circularBoundary = CircularBoundary(_center, radius));

    for (int i = 0; i < count; i++) {
      final angle = i * 2 * pi / count;
      final offset =
          Vector2(cos(angle), sin(angle)) *
          radius *
          0.9 *
          Random().nextDouble();

      final pos = _center + offset; // world-space spawn pos
      _enemyBuilders.addAll([
        {'builder': () => Ufo(pos, cluster: this), 'weight': 0.3},
        {'builder': () => MonsterA(pos, cluster: this), 'weight': 0.15},
        {'builder': () => MonsterB(pos, cluster: this), 'weight': 0.15},
        {'builder': () => MonsterC(pos, cluster: this), 'weight': 0.1},
        {'builder': () => MonsterD(pos, cluster: this), 'weight': 0.15},
        {'builder': () => MonsterE(pos, cluster: this), 'weight': 0.15},
      ]);
      _addEnemies();
    }
  }

  void _addEnemies() {
    final double rand = Random().nextDouble();
    double cumulative = 0;

    for (final e in _enemyBuilders) {
      cumulative += e['weight'] as double;
      if (rand < cumulative) {
        final enemy = ((e['builder'])! as Function)() as MovingClusterObject;
        _enemies.add(enemy);
        game.world.add(enemy);
        break;
      }
    }
  }

  void reset() {
    _center.setFrom(position + size / 2);
    circularBoundary.center.setFrom(_center);
    circularBoundary.radius = radius;
    circularBoundary.reset();
    for (final enemy in _enemies) {
      enemy.reset();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}
