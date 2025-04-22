import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/lander.dart';
import 'package:red_ocelot/components/landing_platform.dart';
import 'package:red_ocelot/red_ocelet_game.dart';

class RedOceletWorld extends World with HasGameReference<RedOceletGame> {
  RedOceletWorld() : super();
  final paint = Paint()..color = Colors.deepPurple;
  late Lander lander;
  late LandingPlatform platform;

  @override
  FutureOr<void> onLoad() {
    final viewSize = game.camera.viewport;
    print("View size: $viewSize");
    lander = Lander()..position = Vector2(500, 100);
    add(lander);

    platform = LandingPlatform(game.size);
    add(platform);
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
