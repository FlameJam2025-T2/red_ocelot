import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/red_ocelet_game.dart';

class RedOceletWorld extends World with HasGameReference<RedOceletGame> {
  RedOceletWorld() : super();
  final paint = Paint()..color = Colors.deepPurple;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, game.size.x, game.size.y), paint);
  }
}
