import 'dart:ui';

import 'package:flame/components.dart';
import 'package:red_ocelot/red_ocelet_game.dart';

class MinimapComponent extends PositionComponent
    with HasGameRef<RedOceletGame> {
  final CameraComponent minimapCamera;

  MinimapComponent({
    required this.minimapCamera,
    Vector2? size,
    Vector2? position,
  }) {
    this.size = Vector2(150, 150);
    this.position = Vector2(500, 300);
    priority = 1000; // render on top
  }

  @override
  void render(Canvas canvas) {
    // Save the current canvas state
    canvas.save();

    // Translate canvas to minimap's position
    canvas.translate(position.x, position.y);

    // Clip to the minimap area
    canvas.clipRect(Rect.fromLTWH(0, 0, size.x, size.y));

    // Set up a scale to shrink the world into the minimap
    final double scaleFactor = size.x / 1000; // Adjust based on your world size
    canvas.scale(scaleFactor);

    // Render the world manually using the minimap camera
    minimapCamera.render(canvas);

    canvas.restore();
  }

  @override
  void update(double dt) {
    minimapCamera.update(dt); // Keep the minimap camera updated
  }
}
