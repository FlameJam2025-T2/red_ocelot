import 'dart:async';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';
import 'package:red_ocelot/components/flame_shaders/sampler_camera.dart';
import 'package:red_ocelot/components/hud.dart';
import 'package:red_ocelot/components/minimap.dart';
import 'package:red_ocelot/components/player/sundiver.dart';
//import 'package:red_ocelot/components/samplers/laser.dart';
import 'package:red_ocelot/components/samplers/starfield.dart';
import 'package:red_ocelot/config/keys.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_world.dart';

enum GameState {
  loading, // Initial state during loading
  menu, // At main menu
  playing, // Game is active
  paused, // Game is paused
  gameOver, // Game is over
}

class RedOcelotGame extends Forge2DGame
    with SingleGameInstance, HasKeyboardHandlerComponents {
  late final RouterComponent router;
  late SunDiver sundiver;
  late RedOcelotMap clusterMap;
  final Vector2 viewportResolution;
  SamplerCamera? starfieldCamera;
  //  SamplerCamera? laserCamera;
  final Future<FragmentProgram> _starfieldShader = FragmentProgram.fromAsset(
    'shaders/starfield.frag',
  );
  final Future<FragmentProgram> _laserFrag = FragmentProgram.fromAsset(
    'shaders/laser.frag',
  );
  late final FragmentProgram starfieldFrag;
  late final FragmentShader laserShader;

  GameState _gameState = GameState.loading;
  bool _gameInitialized = false;

  int totalScore = 0;
  int totalEnemiesKilled = 0;

  RedOcelotGame({required this.viewportResolution}) : super();

  // factory method for gamefactory, without requiring this.viewportResolution
  static RedOcelotGame Function() newGameWithViewport(
    Vector2 viewportResolution,
  ) {
    return () => RedOcelotGame(viewportResolution: viewportResolution);
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
    starfieldFrag = await _starfieldShader;

    // // Load the laser shader
    laserShader = (await _laserFrag).fragmentShader();
    // laserCamera = SamplerCamera.withFixedResolution(
    //   samplerOwner: LaserSamplerOwner(laserShader.fragmentShader(), this),
    //   width: 100 * gameUnit,
    //   height: 10 * gameUnit,
    //   world: world,
    //   pixelRatio: 1.0,
    // );
    // add(laserCamera!);

    camera = CameraComponent(
      viewport: FixedSizeViewport(viewportResolution.x, viewportResolution.y),
    );

    await _setZoom(size: viewportResolution);

    camera.viewfinder.position = size / 2;

    camera.setBounds(RedOcelotMap.bounds);

    // camera.viewport.add(FpsTextComponent());
    camera.viewport.add(HUDComponent()..position = Vector2(size.x - 200, 50));

    _gameState = GameState.menu;

    // Pause until ready
    pauseEngine();
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    clusterMap = RedOcelotMap();
    final RedOcelotWorld redOcelotWorld = RedOcelotWorld(map: clusterMap);
    world = redOcelotWorld;

    starfieldCamera = SamplerCamera.withFixedResolution(
      samplerOwner: StarfieldSamplerOwner(starfieldFrag.fragmentShader(), this),
      width: viewportResolution.x,
      height: viewportResolution.y,
      world: world,
      pixelRatio: 1.0,
    );

    sundiver = SunDiver(
      size: Vector2(shipSize, shipSize),
      // todo: Randomize
      startPos: Vector2(550 * gameUnit, 330 * gameUnit),
    );

    camera.follow(sundiver);

    await world.add(starfieldCamera!);
    await world.add(sundiver);

    _gameInitialized = true;
    if (kDebugMode) {
      camera.viewport.add(FpsTextComponent());
    }
    camera.viewport.add(
      MinimapHUD()
        ..position = Vector2(150, 200)
        ..size = Vector2(200, 200),
    );
  }

  void joystickInput(Vector2 input) {
    sundiver.handlJoystickInput(input);
  }

  void startGame() {
    if (_gameState == GameState.playing) return;
    overlays.clear();
    overlays.add(gamepadToggleKey);
    _gameState = GameState.playing;
    resumeEngine();
    if (!FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play('spaceW0rp.mp3', volume: 0.25);
    }
  }

  void gameOver() {
    if (_gameState == GameState.gameOver) return;
    _gameState = GameState.gameOver;

    overlays.add(gameOverKey);
    if (overlays.isActive(gamepadKey)) {
      overlays.remove(gamepadKey);
    }
    if (overlays.isActive(gamepadToggleKey)) {
      overlays.remove(gamepadToggleKey);
    }

    pauseEngine();
  }

  void resetGame() {
    totalScore = 0;
    totalEnemiesKilled = 0;
    (world as RedOcelotWorld).reset();
    sundiver.reset();
  }

  void showMainMenu() {
    pauseEngine();
    overlays.clear();

    overlays.add(mainMenuKey);

    _gameState = GameState.menu;
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
    starfieldCamera?.viewport.size = size;
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
    starfieldCamera?.update(dt);
    // starfield.parallax?.baseVelocity = Vector2(
    //   velocity.x / gameUnit / 2,
    //   velocity.y / gameUnit / 2,
    // );
  }
}
