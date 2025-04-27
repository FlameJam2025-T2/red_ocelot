import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/utils/sprite_utils.dart';

class Ufo extends MovingClusterObject {
  Ufo(super.startPos, {required super.cluster})
    : super(spriteName: SpriteName.ufo, hitPoints: 20, color: Colors.blue) {
    radius = 15 * gameUnit;
    initialVelocity = 50 * gameUnit;
  }
}
