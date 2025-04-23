import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';

class Monster2 extends MovingClusterObject {
  Monster2(super.startPos) : super(color: Colors.green) {
    radius = 23 * gameUnit;
    initialVelocity = 20 * gameUnit;
    letter = 'M2';
  }
}
