import 'package:flutter/material.dart';
import 'package:red_ocelot/components/moving_cluster_object.dart';

class Monster1 extends MovingClusterObject {
  Monster1(super.startPos) : super(color: Colors.red) {
    radius = 10;
    initialVelocity = 20;
    letter = 'M1';
  }
}
