import 'dart:ui';

import 'package:red_ocelot/components/flame_shaders/sampler_canvas.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:flame/extensions.dart';

class LaserSamplerOwner extends SamplerOwner {
  LaserSamplerOwner(super.shader, this.game) : super();

  final RedOcelotGame game;
  double time = 0.0;
  double angle = 0.0;

  @override
  int get passes => 0;

  @override
  void sampler(List<Image> images, Size size, Canvas canvas) {
    shader.setFloatUniforms((value) {
      value
        ..setVector(size.toVector2())
        ..setFloat(time)
        ..setFloat(angle);
    });

    canvas
      ..save()
      ..drawRect(
        Offset.zero & size,
        Paint()
          ..shader = shader
          ..blendMode = BlendMode.lighten,
      )
      ..restore();
  }

  // @override
  // void onGameResize(Vector2 size) {
  //   super.onGameResize(size);
  //   cameraComponent?.viewport.size = size;
  // }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
    angle = game.sundiver.body.angle;
  }
}
