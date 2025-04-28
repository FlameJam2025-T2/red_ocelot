import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';
import 'package:red_ocelot/audio/audio_manager.dart';
import 'package:red_ocelot/components/flame_shaders/sampler_camera.dart';
import 'package:red_ocelot/components/hud.dart';
import 'package:red_ocelot/components/minimap.dart';
import 'package:red_ocelot/components/player/sundiver.dart';
import 'package:red_ocelot/components/samplers/starfield.dart';
import 'package:red_ocelot/config/game_settings.dart';
import 'package:red_ocelot/config/keys.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_world.dart';

enum GameState {
  loading, // Initial state during loading
  menu, // At main menu
  playing, // Game is active
  paused, // Game is paused
  gameOver, // Game is over
  gameWon, // Game is won
}

class RedOcelotGame extends Forge2DGame
    with SingleGameInstance, HasKeyboardHandlerComponents {
  late final RouterComponent router;
  late SunDiver sundiver;
  late RedOcelotMap clusterMap;
  final Vector2 viewportResolution;
  final double devicePixelRatio;
  SamplerCamera? starfieldCamera;
  //  SamplerCamera? laserCamera;
  final Future<FragmentProgram> _starfieldShader = FragmentProgram.fromAsset(
    'shaders/starfield.frag',
  );
  // final Future<FragmentProgram> _laserFrag = FragmentProgram.fromAsset(
  //   'shaders/laser.frag',
  // );
  late final FragmentProgram starfieldFrag;
  //late final FragmentShader laserShader;
  MinimapHUD? minimapHUD;

  GameState _gameState = GameState.loading;
  DateTime? _gameStartTime;
  AudioManager? _audioManager;

  int totalScore = 0;
  int totalEnemiesKilled = 0;

  RedOcelotGame({
    required this.viewportResolution,
    required this.devicePixelRatio,
  }) : super();

  // factory method for gamefactory, without requiring this.viewportResolution
  static RedOcelotGame Function() newGameWithViewport(
    Vector2 viewportResolution,
    double devicePixelRatio,
  ) {
    return () => RedOcelotGame(
      viewportResolution: viewportResolution,
      devicePixelRatio: devicePixelRatio,
    );
  }

  void incrementScore({required int points}) {
    totalScore += points;
    if (kDebugMode) {
      print("Score: $totalScore");
    }
  }

  String elapsedTime() {
    if (_gameStartTime == null) return "00:00";
    final elapsed = DateTime.now().difference(_gameStartTime!);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
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
    starfieldCamera?.viewfinder.zoom = zoom;
  }

  AudioManager get audioManager {
    _audioManager ??= AudioManager();
    return _audioManager!;
  }

  set audioManager(AudioManager audioManager) {
    _audioManager = audioManager;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await loadSprite('sundiver.png');

    // final g = SineWaveGenerator(
    //   frequency: 440,
    //   amplitude: 0.1,
    //   sampleRate: 44100,
    //   bufferSize: 1024,
    // );
    // final audioStream = GeneratedAudio()..initFromGenerator(g);
    // final completer = Completer<bool>();
    // Future.delayed(const Duration(seconds: 1), () {
    //   completer.complete(true);
    // });
    // audioStream.pushGenerator(g, completer.future);

    // Load the shader program
    starfieldFrag = await _starfieldShader;

    // // Load the laser shader
    // laserShader = (await _laserFrag).fragmentShader();
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
    camera.viewport.add(HUDComponent()..position = Vector2(size.x - 110, 10));

    _gameState = GameState.menu;

    // Pause until ready
    pauseEngine();
  }

  // constrain the max resolution of the shader's long side to 512px
  // but maintain the aspect ratio
  static Vector2 limitedShaderSize(Vector2 resolution) {
    const double maxShaderSize = 10;
    final double aspectRatio = resolution.x / resolution.y;
    if (resolution.x < maxShaderSize && resolution.y < maxShaderSize) {
      return Vector2(resolution.x, resolution.y);
    } else if (resolution.x > resolution.y) {
      return Vector2(maxShaderSize, maxShaderSize / aspectRatio);
    } else {
      return Vector2(maxShaderSize * aspectRatio, maxShaderSize);
    }
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    clusterMap = RedOcelotMap();
    final RedOcelotWorld redOcelotWorld = RedOcelotWorld(map: clusterMap);
    world = redOcelotWorld;

    sundiver = SunDiver(
      size: Vector2(shipSize, shipSize),
      // todo: Randomize
      startPos: Vector2(0, 0),
    );

    starfieldCamera = SamplerCamera(
      samplerOwner: StarfieldSamplerOwner(starfieldFrag.fragmentShader(), this),
      viewport: FixedSizeViewport(viewportResolution.x, viewportResolution.y),
      world: world,
      pixelRatio: devicePixelRatio,
    );

    camera.follow(sundiver);

    await clusterMap.add(starfieldCamera!);
    await world.add(sundiver);

    if (kDebugMode) {
      camera.viewport.add(FpsTextComponent());
    }
    final shortestSide = min(viewportResolution.x, viewportResolution.y);
    final hudSize = shortestSide * 0.3;
    final hudPos = hudSize / 2 + shortestSide * 0.05;

    camera.viewport.add(
      minimapHUD =
          MinimapHUD()
            ..position = Vector2(hudPos, hudPos)
            ..size = Vector2(hudSize, hudSize)
            ..hudSize = hudSize,
    );
  }

  void joystickInput(Vector2 input) async {
    await sundiver.reactToJoystickInput(input);
  }

  void startGame() {
    if (_gameState == GameState.playing) return;
    overlays.clear();
    overlays.add(gamepadToggleKey);
    _gameState = GameState.playing;
    _gameStartTime = DateTime.now();
    resumeEngine();
  }

  void gameOver() {
    if (_gameState == GameState.gameOver) return;
    _gameState = GameState.gameOver;

    final gameDuration =
        _gameStartTime != null
            ? DateTime.now().difference(_gameStartTime!)
            : const Duration(seconds: 0);
    final highScore = HighScore(gameDuration, totalScore);
    GameSettings().addHighScore(highScore);

    overlays.add(gameOverKey);
    if (overlays.isActive(gamepadKey)) {
      overlays.remove(gamepadKey);
    }
    if (overlays.isActive(gamepadToggleKey)) {
      overlays.remove(gamepadToggleKey);
    }

    pauseEngine();
  }

  void gameWon() {
    if (_gameState == GameState.gameWon) return;
    _gameState = GameState.gameWon;

    final gameDuration =
        _gameStartTime != null
            ? DateTime.now().difference(_gameStartTime!)
            : const Duration(seconds: 0);
    final highScore = HighScore(gameDuration, totalScore);
    GameSettings().addHighScore(highScore);

    overlays.add(gameWonKey);
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

    if (kDebugMode) {
      print("Game resized to $size");
    }
    // Update the camera's viewport size
    camera.viewport.size = size;
    // Update the zoom level based on the new size
    _setZoom(size: size);
    // update the minimap HUD size and position

    if (minimapHUD != null) {
      final shortestSide = min(size.x, size.y);
      final hudSize = shortestSide * 0.3;
      final hudPos = hudSize / 2 + shortestSide * 0.05;
      minimapHUD!.hudSize = hudSize;
      minimapHUD!.size = Vector2(hudSize, hudSize);
      minimapHUD!.position = Vector2(hudPos, hudPos);
    }
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

  @override
  void onDispose() {
    super.onDispose();
    if (kDebugMode) {
      print("Disposing game");
    }
    _gameState = GameState.loading;
    _gameStartTime = null;
    audioManager.dispose();
  }
}
