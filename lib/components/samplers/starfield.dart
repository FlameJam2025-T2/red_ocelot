import 'dart:ui';

import 'package:red_ocelot/components/flame_shaders/sampler_canvas.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:flame/extensions.dart';

class StarfieldSamplerOwner extends SamplerOwner {
  StarfieldSamplerOwner(super.shader, this.game) : super();

  final RedOcelotGame game;
  Vector2 cumulativeOffset = Vector2.zero();
  Vector2 position = Vector2.zero();

  @override
  int get passes => 0;

  @override
  void sampler(List<Image> images, Size size, Canvas canvas) {
    // final origin = cameraComponent!.visibleWorldRect.topLeft.toVector2();
    shader.setFloatUniforms((value) {
      value
        ..setVector(size.toVector2())
        ..setFloat(cumulativeOffset.x)
        ..setFloat(cumulativeOffset.y);
    });

    canvas
      ..save()
      ..drawRect(
        Offset.zero & size,
        Paint()..shader = shader,
        //  ..blendMode = BlendMod,
      )
      ..restore();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Calculate how much the position changed this frame
    Vector2 velocityThisFrame = game.sundiver.body.linearVelocity.scaled(dt);

    // Add to our cumulative offset
    cumulativeOffset.add(velocityThisFrame.scaled(0.001));
  }
}
