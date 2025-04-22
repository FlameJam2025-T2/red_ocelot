import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/extensions.dart';

import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/player/sundiver.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:red_ocelot/red_ocelet_world.dart';

class RedOceletGame extends Forge2DGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late final RouterComponent router;
  late SunDiver sundiver;
  final Vector2 viewportResolution;
  late final ParallaxComponent starfield;

  RedOceletGame({required this.viewportResolution})
    : super(
        camera: CameraComponent(
          viewport: FixedSizeViewport(
            viewportResolution.x,
            viewportResolution.y,
          ),
        ),
      );

  // factory method for gamefactory, without requiring this.viewportResolution
  static RedOceletGame Function() newGameWithViewport(
    Vector2 viewportResolution,
  ) {
    return () => RedOceletGame(viewportResolution: viewportResolution);
  }

  @override
  Future<void> onLoad() async {
    RedOceletWorld redOceletWorld = RedOceletWorld();
    world = redOceletWorld;
    world.add(RedOcelotMap());

    world.add(sundiver = SunDiver());
    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1.0;
    camera.setBounds(RedOcelotMap.bounds);
    camera.follow(sundiver);

    camera.viewport.add(FpsTextComponent());

    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('temp_stars_0.png'),
        ParallaxImageData('temp_stars_1.png'),
        ParallaxImageData('temp_stars_2.png'),
      ],
      baseVelocity: Vector2.zero(),
      alignment: Alignment.center,
      repeat: ImageRepeat.repeat,

      velocityMultiplierDelta: Vector2(5, 5),
    );

    camera.viewport.add(starfield = parallax);
  }

  @override
  void onGameResize(Vector2 size) {
    // Update the camera's viewport size
    camera.viewport.size = size;
    super.onGameResize(size);
  }

  @override
  void render(Canvas canvas) {
    // Render your game here
    super.render(canvas);
  }

  @override
  void update(double dt) {
    // Update your game logic here
    super.update(dt);
    // update parallax based on the sundiver's velocity
    final velocity = sundiver.velocity;
    starfield.parallax?.baseVelocity = Vector2(
      velocity.x / 10,
      velocity.y / 10,
    );
  }
}
