import 'dart:math' as math;
import 'dart:ui';

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

    for (int i = 0; i < clusterCount; i++) {
      final cluster = game.clusterMap.clusters[i];
      Vector2 clusterPosition = cluster.position * hudSize / 2 / mapSize;
      canvas.drawCircle(
        Offset(clusterPosition.x, clusterPosition.y),
        350 * gameUnit * hudSize / 2 / mapSize,
        clusterPaint,
      );

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
    Vector2 minimapSundriverPosition =
        game.sundiver.position * hudSize / 2 / mapSize;

    List<Offset> transformVertices({
      required List<Offset> vertices,
      required Offset offset,
      required double rotation, // in radians
    }) {
      final cosTheta = math.cos(rotation);
      final sinTheta = math.sin(rotation);

      return vertices.map((vertex) {
        final rotatedX = vertex.dx * cosTheta - vertex.dy * sinTheta;
        final rotatedY = vertex.dx * sinTheta + vertex.dy * cosTheta;
        return Offset(rotatedX + offset.dx, rotatedY + offset.dy);
      }).toList();
    }

    final vertices = Vertices(
      VertexMode.triangles,
      transformVertices(
        vertices: [
          Offset(0, -75 * gameUnit), // Top point
          Offset(-50 * gameUnit, 75 * gameUnit), // Bottom left
          Offset(50 * gameUnit, 75 * gameUnit), // Bottom right
        ],
        offset: Offset(minimapSundriverPosition.x, minimapSundriverPosition.y),
        rotation: game.sundiver.angle,
      ),
    );

    canvas.drawVertices(vertices, BlendMode.srcOver, shipPaint);

    // Draw the minimap border

    super.render(canvas);
  }
}
