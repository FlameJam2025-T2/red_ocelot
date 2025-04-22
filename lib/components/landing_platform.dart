import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:red_ocelot/red_ocelet_game.dart';

class LandingPlatform extends PositionComponent
    with HasGameReference<RedOceletGame> {
  late FragmentProgram shaderProgram;
  FragmentShader? shader;
  double temperature = 0;
  bool heatingUp = true;

  final double maxTemperature = 1.0;
  final double minTemperature = 0.0;
  final double rate = 0.3; // speed of heating/cooling

  LandingPlatform(Vector2 gameSize) {
    position = Vector2(1000 / 2 - 100, 600 - 40);
    size = Vector2(200, 40);
  }

  @override
  FutureOr<void> onLoad() async {
    shaderProgram = await FragmentProgram.fromAsset('shaders/heat_shader.frag');
    shader = shaderProgram.fragmentShader();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (heatingUp) {
      temperature += rate * dt;
      if (temperature >= maxTemperature) {
        temperature = maxTemperature;
        heatingUp = false;
      }
    } else {
      temperature -= rate * dt;
      if (temperature <= minTemperature) {
        temperature = minTemperature;
        heatingUp = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (shader != null) {
      final t = game.currentTime();
      shader!
        ..setFloat(0, t) // u_time
        ..setFloat(1, temperature); // u_temperature
      final paint = Paint()..shader = shader!;
      canvas.drawRect(size.toRect(), paint);
    }
  }
}
