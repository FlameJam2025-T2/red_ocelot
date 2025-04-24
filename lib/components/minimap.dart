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
    this.size = size ?? Vector2(150, 150);
    this.position = position ?? Vector2(0, 0);
    priority = 1000;
  }
  @override
  Future<void> onLoad() async {
    super.onLoad();
    print("🛰️ MinimapComponent onLoad");
    print("   ↳ Size: $size");
    print("   ↳ Position: $position");
  }

  @override
  void render(Canvas canvas) {
    print("🎨 MinimapComponent render tick");
    print("   ↳ Rendering at: $position with size $size");
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.x, size.y));

    // ✅ draw background for visibility
    // final paint = Paint()..color = const Color(0x8800FF00);
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

    final scaleFactor = size.x / 1000;
    canvas.scale(scaleFactor);
    minimapCamera.render(canvas);
    canvas.restore();
  }

  @override
  void update(double dt) {
    minimapCamera.update(dt); // Keep the minimap camera updated
  }
}
