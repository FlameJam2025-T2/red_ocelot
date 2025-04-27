import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/utils/sprite_utils.dart';

class MonsterD extends MovingClusterObject {
  MonsterD(super.startPos, {required super.cluster})
    : super(
        spriteName: SpriteName.monsterD,
        hitPoints: 8,
        color: Colors.green,
      ) {
    radius = 9 * gameUnit;
    initialVelocity = 20 * gameUnit;
  }
}
