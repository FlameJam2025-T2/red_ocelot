import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
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

extension ClusterRemaining on List<Cluster> {
  int get remaining => where((c) => c._enemies.isNotEmpty).length;
  int get remainingEnemies => fold(0, (sum, c) => sum + c._enemies.length);
}

class Cluster extends PositionComponent with HasGameReference<RedOcelotGame> {
  final int count;
  double standardDeviation = 4 * gameUnit;
  double radius;
  final double percentageUFO = 0.2;
  final double percentageMonster1 = 0.5;

  int clusterIndex;
  late CircularBoundary circularBoundary;
  @override
  late Vector2 center;
  List<Map<String, dynamic>> _enemyBuilders = [];
  List<MovingClusterObject> _enemies = [];

  Cluster({
    required this.clusterIndex,
    required this.count,
    required this.radius,
  });

  @override
  Future<void> onLoad() async {
    size = Vector2.all(radius * 2);
    _addClusterComponents();
    super.onLoad();
  }

  void _addClusterComponents() {
    center = position + size / 2; // world space center

    game.world.add(circularBoundary = CircularBoundary(center, radius));

    for (int i = 0; i < count; i++) {
      final angle = i * 2 * pi / count;
      final offset =
          Vector2(cos(angle), sin(angle)) *
          radius *
          0.9 *
          Random().nextDouble();

      final pos = center + offset; // world-space spawn pos
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

  int remainingEnemies() {
    return _enemies.length;
  }

  removeEnemy(MovingClusterObject enemy) {
    _enemies.remove(enemy);
    if (_enemies.isEmpty) {
      game.clusterMap.clusters.remove(this);
      game.clusterMap.numberClusterObjects[this] = 0;
    }
  }

  void reset() {
    _enemies = [];
    _enemyBuilders = [];
    List<BodyComponent> bodies =
        game.world.children.whereType<BodyComponent>().toList();
    for (final body in bodies) {
      if (body is MovingClusterObject) {
        body.removeFromParent();
      }
      if (body is CircularBoundary) {
        body.removeFromParent();
      }
    }
  }
}
