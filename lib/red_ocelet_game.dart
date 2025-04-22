import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/extensions.dart';

import 'package:flame/game.dart';
import 'package:red_ocelot/components/player/sundiver.dart';
import 'package:red_ocelot/red_ocelet_world.dart';

class RedOceletGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late final RouterComponent router;
  late SunDiver sundiver;
  final Vector2 viewportResolution;

  RedOceletGame({required this.viewportResolution})
    : super(
        camera: CameraComponent.withFixedResolution(
          width: viewportResolution.x,
          height: viewportResolution.y,
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

    world.add(sundiver = PlayerSunDiver());
    camera.setBounds(RedOcelotMap.bounds);
    camera.follow(sundiver);

    world.add(FpsTextComponent());
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
  }
}
