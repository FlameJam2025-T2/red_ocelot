import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/utils/sprite_utils.dart';

class MonsterB extends MovingClusterObject {
  MonsterB(super.startPos)
    : super(
        spriteName: SpriteName.monsterB,
        hitPoints: 4,
        color: Colors.green,
      ) {
    radius = 15 * gameUnit;
    initialVelocity = 20 * gameUnit;
  }
}
