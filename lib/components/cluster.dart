import 'dart:math' as math;

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

double gaussianRandom({double mean = 0, double stdDev = 1}) {
  final rand = math.Random();
  final u1 = rand.nextDouble();
  final u2 = rand.nextDouble();
  final z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
  return z0 * stdDev + mean;
}

class Cluster extends PositionComponent with HasGameReference<Forge2DGame> {
  final int count;
  double standardDeviation = 4 * gameUnit;
  final double radius;
  final double percentageUFO = 0.2;
  final double percentageMonster1 = 0.5;

  Cluster({required this.count, required this.radius});

  @override
  Future<void> onLoad() async {
    final center = size / 2;

    add(CircularBoundary(center, radius));
    final actualCount = math.max(
      1,
      gaussianRandom(mean: count.toDouble(), stdDev: standardDeviation).round(),
    );

    for (int i = 0; i < actualCount; i++) {
      final angle = i * 2 * math.pi / actualCount;
      final pos =
          center +
          Vector2(math.cos(angle), math.sin(angle)) *
              radius *
              0.9 *
              math.Random().nextDouble();

      final enemies = [
        {'builder': () => Ufo(pos), 'weight': 0.3},

        {'builder': () => MonsterA(pos), 'weight': 0.15},
        {'builder': () => MonsterB(pos), 'weight': 0.15},
        {'builder': () => MonsterC(pos), 'weight': 0.1},
        {'builder': () => MonsterD(pos), 'weight': 0.15},
        {'builder': () => MonsterE(pos), 'weight': 0.15},
      ];

      final double rand = math.Random().nextDouble();
      double cumulative = 0;

      for (final e in enemies) {
        cumulative += e['weight'] as double;
        if (rand < cumulative) {
          add(((e['builder'])! as Function)() as BodyComponent);
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
