import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';

class Ufo extends MovingClusterObject {
  Ufo(super.startPos) : super(color: Colors.blue) {
    radius = 15;
    initialVelocity = 50;
    letter = 'U';
  }
}
