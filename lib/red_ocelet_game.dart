import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/extensions.dart';

import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/player/sundiver.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelet_world.dart';
import 'package:flame_audio/flame_audio.dart';

class RedOceletGame extends Forge2DGame
    with SingleGameInstance, HasKeyboardHandlerComponents {
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

  /// Sets the zoom level so that the the smallest side of the screen is
  /// at least shipSizeMultiplier times the size of the ship.
  /// This is useful for ensuring that the ship is always visible on the screen
  /// and that all devices show a similar view of the game world.
  Future<void> _setZoom({
    required Vector2 size,
    double shipSizeMultiplier = 20,
  }) async {
    final minSide = size.x < size.y ? size.x : size.y;
    final zoom = minSide / (shipSizeMultiplier * shipSize);
    camera.viewfinder.zoom = zoom;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadSprite('sundiver.png');
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('spaceW0rp.mp3', volume: 0.05);
    RedOceletWorld redOceletWorld = RedOceletWorld();
    world = redOceletWorld;
    world.add(RedOcelotMap());
    await _setZoom(size: viewportResolution);

    await world.add(
      sundiver = SunDiver(
        size: Vector2(shipSize, shipSize),
        // startPos: Vector2(RedOcelotMap.size / 2, RedOcelotMap.size / 2),
        startPos: Vector2(550 * gameUnit, 330 * gameUnit),
      ),
    );
    camera.viewfinder.position = size / 2;

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

      velocityMultiplierDelta: Vector2(1.1, 1.1),
    );

    await add(starfield = parallax);
  }

  void joystickInput(Vector2 input) {
    sundiver.handlJoystickInput(input);
  }

  void buttonInput(bool pressed) {
    if (pressed) {
      sundiver.startShooting();
    } else {
      sundiver.stopShooting();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    // Update the camera's viewport size
    camera.viewport.size = size;
    // Update the zoom level based on the new size
    _setZoom(size: size);
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
    final velocity = sundiver.body.linearVelocity;
    starfield.parallax?.baseVelocity = Vector2(
      velocity.x / gameUnit / 2,
      velocity.y / gameUnit / 2,
    );
  }

  @override
  void onDetach() {
    super.onDetach();
    FlameAudio.bgm.stop();
  }

  @override
  void onRemove() {
    super.onRemove();
    FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
  }
}
