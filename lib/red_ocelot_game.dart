import 'dart:async';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:red_ocelot/components/flame_shaders/sampler_camera.dart';
import 'package:red_ocelot/components/hud.dart';
import 'package:red_ocelot/components/minimap.dart';
import 'package:red_ocelot/components/player/sundiver.dart';
//import 'package:red_ocelot/components/samplers/laser.dart';
import 'package:red_ocelot/components/samplers/starfield.dart';
import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/red_ocelot_world.dart';

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
  late final FragmentShader laserShader;

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
    final shader = await _starfieldShader;
    starfieldCamera = SamplerCamera(
      samplerOwner: StarfieldSamplerOwner(shader.fragmentShader(), this),
      viewport: FixedSizeViewport(viewportResolution.x, viewportResolution.y),
      world: world,
      pixelRatio: 1.0,
    );
    add(starfieldCamera!);

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

    RedocelotWorld redocelotWorld = RedocelotWorld();
    world = redocelotWorld;
    clusterMap = RedOcelotMap();
    world.add(clusterMap);

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
    camera.viewport.add(
      MinimapHUD()
        ..position = Vector2(150, 200)
        ..size = Vector2(200, 200),
    );
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
    starfieldCamera!.update(dt);
    // starfield.parallax?.baseVelocity = Vector2(
    //   velocity.x / gameUnit / 2,
    //   velocity.y / gameUnit / 2,
    // );
  }
}
