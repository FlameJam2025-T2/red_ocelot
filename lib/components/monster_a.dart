import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/utils/sprite_utils.dart';

class MonsterA extends MovingClusterObject {
  MonsterA(super.startPos)
    : super(spriteName: SpriteName.monsterA, color: Colors.red) {
    radius = 10 * gameUnit;
    initialVelocity = 20 * gameUnit;
    letter = 'M1';
  }
}
