import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/cluster.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

class HUDComponent extends PositionComponent
    with HasGameReference<RedOcelotGame> {
  int score;
  final TextPainter textPainter;
  final double boxWidth;
  final double boxHeight;
  final Paint boxPaint;
  final TextStyle textStyle = TextStyle(
    fontSize: 12,
    color: Colors.white.withAlpha(200),
  );

  HUDComponent({
    this.score = 0,
    this.boxWidth = 100,
    this.boxHeight = 80,
    Vector2? position,
  }) : textPainter = TextPainter(
         textDirection: TextDirection.ltr,
         textAlign: TextAlign.right,
       ),
       boxPaint =
           Paint()
             ..color = const Color.fromARGB(255, 204, 220, 234).withAlpha(50) {
    this.position = position ?? Vector2.zero();
    size = Vector2(boxWidth, boxHeight);
  }

  @override
  void update(double dt) {
    // final tp = textPaint.toTextPainter(text);
    if (game.clusterMap.clusters.remainingEnemies == 0) {
      game.gameWon();
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // Draw the background box
    canvas.drawRect(size.toRect(), boxPaint);

    // Draw the score text centered
    final text = TextSpan(
      style: textStyle,
      text:
          '${game.elapsedTime()}\nScore: ${game.totalScore}\nClusters: ${game.clusterMap.clusters.remaining}\nEnenies: ${game.clusterMap.clusters.remainingEnemies}',
    );

    textPainter.text = text;
    textPainter.layout();
    final offset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }
}
