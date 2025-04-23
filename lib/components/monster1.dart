import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';

class Monster1 extends MovingClusterObject {
  Monster1(super.startPos) : super(color: Colors.red) {
    radius = 10 * gameUnit;
    initialVelocity = 20 * gameUnit;
    letter = 'M1';
  }
}
