// Updated StarfieldBackground component with limited resolution rendering

import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/components/flame_shader_limited/shader_component.dart';

class LaserBeam extends ShaderComponent<RedOcelotGame> {
  @override
  LaserBeam(super.shader)
    : super(
        destSize: Vector2(1, 1),
        blendMode: BlendMode.srcOver,
        scaleMode: ScaleMode.stretch,
      ) {
    angle = pi / 2;
  }

  Vector2 _getShaderSize(Vector2 size) {
    final longestSide = max(size.x, size.y);
    return Vector2(longestSide * 0.4 * gameUnit, longestSide * 0.4 * gameUnit);
  }

  // @override
  // void update(double dt) {
  //   super.update(dt);
  // }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    shaderDestSize.setFrom(_getShaderSize(size));
  }

  @override
  void setShaderUniforms(Vector2 renderSize) {
    shader.setFloatUniforms((value) {
      value
        ..setVector(renderSize)
        ..setFloat(time);
    });
  }

  @override
  get destOffset {
    return Offset(-shaderDestSize.x / 2, 0);
  }
}
