import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/utils/sprite_utils.dart';

class MonsterE extends MovingClusterObject {
  MonsterE(super.startPos)
    : super(
        spriteName: SpriteName.monsterE,
        hitPoints: 10,
        color: Colors.green,
      ) {
    radius = 11 * gameUnit;
    initialVelocity = 20 * gameUnit;
  }
}
