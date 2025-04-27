import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

class HUDComponent extends PositionComponent
    with HasGameReference<RedOcelotGame> {
  int score;
  final TextPaint textPaint;
  final double boxWidth;
  final double boxHeight;
  final Paint boxPaint;

  HUDComponent({
    this.score = 0,
    this.boxWidth = 100,
    this.boxHeight = 40,
    Vector2? position,
  }) : textPaint = TextPaint(
         style: const TextStyle(
           fontSize: 16,
           color: Colors.white,
           fontWeight: FontWeight.bold,
         ),
       ),
       boxPaint = Paint()..color = Colors.blue.withAlpha(200) {
    this.position = position ?? Vector2.zero();
    size = Vector2(boxWidth, boxHeight);
  }

  @override
  void render(Canvas canvas) {
    // Draw the background box
    canvas.drawRect(size.toRect(), boxPaint);

    // Draw the score text centered
    final text = 'Score: ${game.totalScore}';
    final tp = textPaint.toTextPainter(text);
    final offset = Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2);
    tp.paint(canvas, offset);
  }
}
