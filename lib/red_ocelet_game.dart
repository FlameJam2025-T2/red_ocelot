import 'dart:async';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:red_ocelot/red_ocelet_world.dart';

class RedOceletGame extends FlameGame {
  late final RouterComponent router;
  @override
  Future<void> onLoad() async {
    super.onLoad();
    RedOceletWorld redOceletWorld = RedOceletWorld();
    world = redOceletWorld;

    camera =
        CameraComponent.withFixedResolution(
            width: 1000,
            height: 600,
            world: world,
            viewfinder: Viewfinder(),
          )
          ..moveTo(Vector2(500, 300))
          ..viewfinder.zoom = 1.0;

    router = RouterComponent(
      routes: {'red-ocelet-game': WorldRoute(() => redOceletWorld)},
      initialRoute: 'red-ocelet-game',
    );

    add(router);

    world.add(FpsTextComponent());
    camera.viewfinder.zoom = 1.0;
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
