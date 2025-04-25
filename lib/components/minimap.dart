import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

class MinimapHUD extends PositionComponent
    with HasGameReference<RedOcelotGame> {
  Paint paintBox =
      Paint()
        ..color = const Color.fromARGB(255, 196, 23, 23)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
  Paint shipPaint = Paint()..color = Colors.red;
  Paint clusterPaint = Paint()..color = const Color.fromARGB(255, 27, 7, 118);
  final fillPaint =
      Paint()
        ..color = Colors.grey.withOpacity(0.3) // adjust opacity to your liking
        ..style = PaintingStyle.fill;

  double hudSize = 300;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTRB(-hudSize / 2, -hudSize / 2, hudSize / 2, hudSize / 2),
      paintBox,
    );
    canvas.drawRect(
      Rect.fromLTRB(-hudSize / 2, -hudSize / 2, hudSize / 2, hudSize / 2),
      fillPaint,
    );
    double viewFindersize =
        5000 / game.camera.viewfinder.zoom * hudSize / 2 / mapSize;
    for (int i = 0; i < clusterCount; i++) {
      final cluster = game.clusterMap.clusters[i];
      Vector2 clusterPosition = cluster.position * hudSize / 2 / mapSize;

      // Draw the cluster circle
      canvas.drawCircle(
        Offset(clusterPosition.x, clusterPosition.y),
        350 * gameUnit * hudSize / 2 / mapSize,
        clusterPaint,
      );

      // Get the number of objects left in the cluster
      final int objectsLeft =
          game.clusterMap.numberClusterObjects[i]; // adjust based on your model

      // Draw the number at the cluster position
      final textSpan = TextSpan(
        text: '$objectsLeft',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          clusterPosition.x - textPainter.width / 2,
          clusterPosition.y - textPainter.height / 2,
        ),
      );
    }

    // Draw the ship
    Vector2 minimapSundriverPosition =
        game.sundiver.position * hudSize / 2 / mapSize;
    canvas.drawCircle(
      Offset(minimapSundriverPosition.x, minimapSundriverPosition.y),
      5,
      shipPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        -viewFindersize / 2 + minimapSundriverPosition.x,
        -viewFindersize / 2 + minimapSundriverPosition.y,
        viewFindersize,
        viewFindersize,
      ),

      paintBox,
    );

    // Draw the minimap border

    super.render(canvas);
  }
}
