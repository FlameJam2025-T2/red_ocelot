import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/cluster.dart';
import 'package:red_ocelot/red_ocelet_game.dart';

class RedOceletWorld extends Forge2DWorld with HasGameReference<RedOceletGame> {
  RedOceletWorld() : super(gravity: Vector2.zero());
  final paint = Paint()..color = Colors.deepPurple;
  late Cluster cluster;

  @override
  FutureOr<void> onLoad() {
    final viewSize = game.camera.viewport;
    print("View size: $viewSize");
    cluster = Cluster(count: 20, radius: 250)..position = Vector2(500, 300);
    add(cluster);

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, game.size.x, game.size.y), paint);
  }
}
