// Updated StarfieldBackground component with limited resolution rendering

import 'package:flame/extensions.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/components/flame_shader_limited/shader_component.dart';

class StarfieldBackground extends ShaderComponent<RedOcelotGame> {
  final Vector2 cumulativeOffset = Vector2.zero();

  final Vector2 _lastOffset = Vector2.zero();

  StarfieldBackground(
    super.shader, {
    required super.destSize,
    super.maxShaderDimension,
    super.blendMode,
    super.destOffsetFromCenter,
    super.scaleMode,
  });

  @override
  void update(double dt) {
    super.update(dt);

    // Calculate movement for parallax effect
    final Vector2 velocityThisFrame = game.sundiver.body.linearVelocity.scaled(
      dt,
    );
    cumulativeOffset.add(velocityThisFrame.scaled(0.01));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    shaderDestSize.setFrom(size);
  }

  @override
  void setShaderUniforms(Vector2 renderSize) {
    shader
      ..setFloat(0, renderSize.x)
      ..setFloat(1, renderSize.y)
      ..setFloat(2, cumulativeOffset.x)
      ..setFloat(3, cumulativeOffset.y);

    _lastOffset.setFrom(cumulativeOffset);
  }

  @override
  bool needsRegeneration() {
    return (_lastOffset - cumulativeOffset).length > 0.0;
  }
}
