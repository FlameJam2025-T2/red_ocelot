import 'dart:typed_data';
import 'dart:ui';
import 'dart:math';

import 'package:red_ocelot/components/flame_shaders/sampler_canvas.dart';
import 'package:red_ocelot/components/flame_shaders/layer.dart';
import 'package:red_ocelot/components/flame_shaders/sampler_camera.dart';
import 'package:red_ocelot/components/player/sundiver.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/red_ocelot_world.dart';
import 'package:flame/extensions.dart';

class StarfieldSamplerOwner extends SamplerOwner {
  StarfieldSamplerOwner(super.shader, this.game);

  final RedocelotGame game;
  double angle = 0.0;
  double time = 0.0;
  double speed = 0.01;
  double distanceDelta = 0.0;
  Vector2 velocity = Vector2.zero();
  Vector2 position = Vector2.zero();
  final Vector2 _mapSize = Vector2.all(mapSize);

  @override
  int get passes => 0;

  @override
  void sampler(List<Image> images, Size size, Canvas canvas) {
    // final origin = cameraComponent!.visibleWorldRect.topLeft.toVector2();

    shader.setFloatUniforms((value) {
      value
        ..setVector(game.viewportResolution)
        ..setFloat(time)
        ..setFloat(velocity.x)
        ..setFloat(velocity.y)
        ..setFloat(speed);
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
    time = dt;
    //print(distanceDelta);
    // calculate the angle based on the velocity
    angle = game.sundiver.body.linearVelocity.scaled(1.0).screenAngle();
    speed = game.sundiver.body.linearVelocity.length * gameUnit;
    velocity.setFrom(game.sundiver.body.linearVelocity);
    // scale the velocity as a proportion of SunDiver max speed
    velocity.scale(1 / (SunDiver.maxSpeed + 1e-10));
    position.setFrom(
      (game.sundiver.body.worldPoint(Vector2.zero()) + _mapSize) *
          1 /
          mapSize /
          2,
    );
    position.multiply(game.viewportResolution);
  }
}
