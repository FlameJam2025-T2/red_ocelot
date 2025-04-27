import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

class MinimapHUD extends PositionComponent
    with HasGameReference<RedOcelotGame> {
  Paint paintBox =
      Paint()
        ..color = const Color.fromARGB(128, 196, 23, 23)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
  Paint shipPaint = Paint()..color = Colors.red;
  Paint clusterPaint = Paint()..color = const Color.fromARGB(128, 27, 7, 118);
  final fillPaint =
      Paint()
        ..color = Colors.grey.withAlpha(50) // adjust opacity to your liking
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
    for (int i = 0; i < clusterCount; i++) {
      final cluster = game.clusterMap.clusters[i];
      Vector2 clusterPosition = cluster.position * hudSize / mapSize;

      // Draw the cluster circle
      canvas.drawCircle(
        Offset(clusterPosition.x, clusterPosition.y),
        350 * gameUnit * hudSize / mapSize / 1.5,
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
        game.sundiver.position * hudSize / mapSize;
    // canvas.drawCircle(
    //   Offset(minimapSundriverPosition.x, minimapSundriverPosition.y),
    //   5,
    //   shipPaint,
    // );

    canvas.drawVertices(
      _getShipVertices(minimapSundriverPosition, game.sundiver.body.angle),
      BlendMode.srcOver,
      shipPaint,
    );

    // Draw the minimap border

    super.render(canvas);
  }

  Vertices _getShipVertices(Vector2 position, double angle) {
    final double size = 10.0; // Size of the ship on the minimap
    final double halfSize = size / 2;

    final List<Offset> vertices =
        <Offset>[
          Offset(0, -halfSize * 1.5), // Top vertex
          Offset(-halfSize, halfSize * 1.5), // Bottom left vertex
          Offset(halfSize, halfSize * 1.5), // Bottom right vertex
        ].map((offset) {
          return Offset(
            position.x + offset.dx * cos(angle) - offset.dy * sin(angle),
            position.y + offset.dx * sin(angle) + offset.dy * cos(angle),
          );
        }).toList();

    return Vertices(
      VertexMode.triangles,
      vertices,
      textureCoordinates: null,
      colors: null,
    );
  }
}
