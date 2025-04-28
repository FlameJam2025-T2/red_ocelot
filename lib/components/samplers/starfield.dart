import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:red_ocelot/components/flame_shaders/sampler_canvas.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:flame/extensions.dart';

class StarfieldSamplerOwner extends SamplerOwner {
  StarfieldSamplerOwner(super.shader, this.game) : super();

  final RedOcelotGame game;
  late final Vector2 viewportSize = Vector2.zero();
  final Vector2 cumulativeOffset = Vector2.zero();
  double time = 0.0;
  double scaleFactor = 1;

  @override
  int get passes => 0;

  @override
  void attachCamera(CameraComponent cameraComponent) {
    super.attachCamera(cameraComponent);
    viewportSize.setFrom(cameraComponent.viewport.size);
  }

  @override
  void sampler(List<Image> images, Size size, Canvas canvas) {
    if (kDebugMode) {
      print('StarfieldSamplerOwner.sampler');
      print(size);
    }
    shader.setFloatUniforms((value) {
      value
        ..setVector(viewportSize)
        ..setFloat(cumulativeOffset.x * scaleFactor)
        ..setFloat(cumulativeOffset.y * scaleFactor)
        ..setFloat(time);
    });
    canvas
      ..save()
      ..drawRect(
        Offset(-viewportSize.x / 2, -viewportSize.y / 2) &
            Size(viewportSize.x, viewportSize.y),
        Paint()
          ..shader = shader
          ..blendMode = BlendMode.srcOver,
      )
      ..clipRect(
        Offset(-viewportSize.x / 2, -viewportSize.y / 2) &
            Size(viewportSize.x, viewportSize.y),
      )
      ..scale(scaleFactor)
      ..restore();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    cameraComponent?.viewport.size = size;
    viewportSize.setFrom(RedOcelotGame.limitedShaderSize(size));
    if (kDebugMode) {
      print('StarfieldSamplerOwner.onGameResize');
      print(cameraComponent?.viewport.size);
    }
    scaleFactor = size.length / viewportSize.length;
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    // Calculate how much the position changed this frame
    Vector2 velocityThisFrame = game.sundiver.body.linearVelocity.scaled(dt);

    // Add to our cumulative offset
    cumulativeOffset.add(velocityThisFrame.scaled(0.0001));
  }
}
