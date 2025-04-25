import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:red_ocelot/components/circular_boundary.dart';
import 'package:red_ocelot/components/monster_a.dart';
import 'package:red_ocelot/components/monster_b.dart';
import 'package:red_ocelot/components/monster_c.dart';
import 'package:red_ocelot/components/monster_d.dart';
import 'package:red_ocelot/components/monster_e.dart';
import 'package:red_ocelot/components/ufo.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

class Cluster extends PositionComponent with HasGameReference<RedOcelotGame> {
  final int count;
  double standardDeviation = 4 * gameUnit;
  final double radius;
  final double percentageUFO = 0.2;
  final double percentageMonster1 = 0.5;

  int clusterIndex;

  Cluster({
    required this.clusterIndex,
    required this.count,
    required this.radius,
  });

  @override
  Future<void> onLoad() async {
    final center = position + size / 2; // world space center

    game.world.add(CircularBoundary(center, radius));

    for (int i = 0; i < count; i++) {
      final angle = i * 2 * pi / count;
      final offset =
          Vector2(cos(angle), sin(angle)) *
          radius *
          0.9 *
          Random().nextDouble();

      final pos = center + offset; // world-space spawn pos

      final enemies = [
        {'builder': () => Ufo(pos, clusterIndex: clusterIndex), 'weight': 0.3},
        {
          'builder': () => MonsterA(pos, clusterIndex: clusterIndex),
          'weight': 0.15,
        },
        {
          'builder': () => MonsterB(pos, clusterIndex: clusterIndex),
          'weight': 0.15,
        },
        {
          'builder': () => MonsterC(pos, clusterIndex: clusterIndex),
          'weight': 0.1,
        },
        {
          'builder': () => MonsterD(pos, clusterIndex: clusterIndex),
          'weight': 0.15,
        },
        {
          'builder': () => MonsterE(pos, clusterIndex: clusterIndex),
          'weight': 0.15,
        },
      ];

      final double rand = Random().nextDouble();
      double cumulative = 0;

      for (final e in enemies) {
        cumulative += e['weight'] as double;
        if (rand < cumulative) {
          game.world.add(((e['builder'])! as Function)() as BodyComponent);
          break;
        }
      }
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}
