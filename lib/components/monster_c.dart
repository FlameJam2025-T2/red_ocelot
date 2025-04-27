import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/utils/sprite_utils.dart';

class MonsterC extends MovingClusterObject {
  MonsterC(super.startPos, {required super.cluster})
    : super(
        spriteName: SpriteName.monsterC,
        hitPoints: 6,
        color: const Color.fromARGB(255, 162, 175, 76),
      ) {
    radius = 12 * gameUnit;
    initialVelocity = 20 * gameUnit;
  }
}
