import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/utils/sprite_utils.dart';

class MonsterD extends MovingClusterObject {
  MonsterD(super.startPos)
    : super(spriteName: SpriteName.monsterD, color: Colors.green) {
    radius = 9 * gameUnit;
    initialVelocity = 20 * gameUnit;
    letter = 'M2';
  }
}
