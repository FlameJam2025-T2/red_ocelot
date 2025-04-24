import 'dart:async';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/components/hud.dart';
import 'package:red_ocelot/components/player/sundiver.dart';
import 'package:red_ocelot/components/samplers/starfield.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_world.dart';
import 'package:red_ocelot/components/flame_shaders/sampler_camera.dart';

class RedocelotGame extends Forge2DGame
    with SingleGameInstance, HasKeyboardHandlerComponents {
  late final RouterComponent router;
  late SunDiver sundiver;
  final Vector2 viewportResolution;
  late final SamplerCamera starfieldCamera;
  final Future<FragmentProgram> _starfieldShader = FragmentProgram.fromAsset(
    'shaders/starfield.frag',
  );

  int totalScore = 0;
  int totalEnemiesKilled = 0;

  RedocelotGame({required this.viewportResolution}) : super();

  // factory method for gamefactory, without requiring this.viewportResolution
  static RedocelotGame Function() newGameWithViewport(
    Vector2 viewportResolution,
  ) {
    return () => RedocelotGame(viewportResolution: viewportResolution);
  }

  void incrementScore({required int points}) {
    totalScore += points;
    print("Score: $totalScore");
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

    // Load the shader program
    final shader = await _starfieldShader;
    starfieldCamera = SamplerCamera.withFixedResolution(
      samplerOwner: StarfieldSamplerOwner(shader.fragmentShader(), this),
      width: viewportResolution.x,
      height: viewportResolution.y,
      world: camera.world,
      pixelRatio: 1.0,
    );
    add(starfieldCamera);

    camera = CameraComponent(
      viewport: FixedSizeViewport(viewportResolution.x, viewportResolution.y),
    );

    RedocelotWorld redocelotWorld = RedocelotWorld();
    world = redocelotWorld;
    world.add(RedOcelotMap());

    await _setZoom(size: viewportResolution);

    await world.add(
      sundiver = SunDiver(
        size: Vector2(shipSize, shipSize),
        startPos: Vector2(550 * gameUnit, 330 * gameUnit),
      ),
    );
    camera.viewfinder.position = size / 2;

    camera.setBounds(RedOcelotMap.bounds);

    camera.follow(sundiver);

    camera.viewport.add(FpsTextComponent());
    camera.viewport.add(HUDComponent()..position = Vector2(size.x - 200, 50));
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
    super.onGameResize(size);
    // Update the camera's viewport size
    camera.viewport.size = size;
    // Update the zoom level based on the new size
    _setZoom(size: size);
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
    starfieldCamera.update(dt);
    // starfield.parallax?.baseVelocity = Vector2(
    //   velocity.x / gameUnit / 2,
    //   velocity.y / gameUnit / 2,
    // );
  }
}
