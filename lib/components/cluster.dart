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
  final Random _rng;

  Cluster({required this.count, required this.radius, Random? rng})
    : _rng = rng ?? Random();

  double gaussianRandom({double mean = 0, double stdDev = 1}) {
    final u1 = _rng.nextDouble();
    final u2 = _rng.nextDouble();
    final z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
    return z0 * stdDev + mean;
  }

  @override
  Future<void> onLoad() async {
    final center = position + size / 2; // world space center

    game.world.add(CircularBoundary(center, radius));

    final actualCount = max(
      1,
      gaussianRandom(mean: count.toDouble(), stdDev: standardDeviation).round(),
    );

    for (int i = 0; i < actualCount; i++) {
      final angle = i * 2 * pi / actualCount;
      final offset =
          Vector2(cos(angle), sin(angle)) * radius * 0.9 * _rng.nextDouble();

      final pos = center + offset; // world-space spawn pos

      final enemies = [
        {'builder': () => Ufo(pos), 'weight': 0.3},
        {'builder': () => MonsterA(pos), 'weight': 0.15},
        {'builder': () => MonsterB(pos), 'weight': 0.15},
        {'builder': () => MonsterC(pos), 'weight': 0.1},
        {'builder': () => MonsterD(pos), 'weight': 0.15},
        {'builder': () => MonsterE(pos), 'weight': 0.15},
      ];

      final double rand = _rng.nextDouble();
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
