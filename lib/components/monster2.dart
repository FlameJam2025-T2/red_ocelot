import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';

class Monster2 extends MovingClusterObject {
  Monster2(super.startPos) : super(color: Colors.green) {
    radius = 23;
    initialVelocity = 20;
    letter = 'M2';
  }
}
