import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';
import 'package:red_ocelot/config/world_parameters.dart';

class Ufo extends MovingClusterObject {
  Ufo(super.startPos) : super(color: Colors.blue) {
    radius = 15 * gameUnit;
    initialVelocity = 50 * gameUnit;
    letter = 'U';
  }
}
