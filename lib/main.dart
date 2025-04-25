import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/config/keys.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/ui/game_over.dart';
import 'package:red_ocelot/ui/menu.dart';
import 'package:red_ocelot/ui/pallette.dart';
import 'package:red_ocelot/ui/gamepad.dart';
import 'package:red_ocelot/util/ltrb.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Ocelot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: colorScheme),
      home: const GameContainer(),
    );
  }
}

class GameContainer extends StatefulWidget {
  const GameContainer({super.key});

  @override
  State<GameContainer> createState() => _GameContainerState();
}

class _GameContainerState extends State<GameContainer> {
  late RedOcelotGame game;

  @override
  Widget build(BuildContext context) {
    FlameAudio.bgm.initialize();
    final double tenpct = max(
      min(
        MediaQuery.of(context).size.width / 10,
        MediaQuery.of(context).size.height / 10,
      ),
      50.0,
    );
    return Scaffold(
      appBar: null,
      body: Center(
        child: GameWidget.controlled(
          gameFactory: RedOcelotGame.newGameWithViewport(
            Vector2(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
          ),
          overlayBuilderMap: {
            mainMenuKey: (_, RedOcelotGame game) {
              return Menu(
                game: game,
                title: 'Red Ocelot',
                items: [
                  MenuItem(
                    title: 'Start Game',
                    onPressed: () {
                      game.startGame();
                    },
                  ),
                  MenuItem(
                    title: 'Settings',
                    onPressed: () {
                      // Handle settings tap
                      game.overlays.add('Settings');
                    },
                  ),
                  MenuItem(
                    title: 'Exit',
                    onPressed: () {
                      // Handle exit tap
                      FlameAudio.bgm.stop();
                      FlameAudio.bgm.dispose();
                    },
                  ),
                ],
              );
            },
            settingsMenuKey: (_, RedOcelotGame game) {
              return Menu(
                game: game,
                backButton: true,
                overlayName: settingsMenuKey,
                title: 'Settings',
                items: [
                  MenuItem(
                    title: 'Audio',
                    onPressed: () {
                      // Handle audio settings tap
                      FlameAudio.bgm.isPlaying
                          ? FlameAudio.bgm.stop()
                          : FlameAudio.bgm.play('spaceW0rp.mp3', volume: 0.05);
                    },
                  ),
                  MenuItem(
                    title: 'Controls',
                    onPressed: () {
                      // Handle controls settings tap
                    },
                  ),
                ],
              );
            },
            gamepadKey: (_, RedOcelotGame game) {
              return Gamepad(
                onButtonPress: () {
                  game.buttonInput(true);
                },
                onButtonRelease: () {
                  game.buttonInput(false);
                },
                onMove: (Vector2 direction) {
                  game.joystickInput(direction);
                },
                joystickPosition: LTRB(bottom: tenpct * 1.5, left: tenpct),
                buttonPosition: LTRB(bottom: tenpct * 1.5, right: tenpct),
                joystickSize: tenpct,
                buttonSize: tenpct,
              );
            },
            gamepadToggleKey: (_, RedOcelotGame game) {
              return GamepadToggle(
                position: LTRB(bottom: tenpct / 2, right: tenpct / 2),
                size: tenpct,
                onPressed:
                    () => {
                      if (game.overlays.isActive(gamepadKey))
                        {game.overlays.remove(gamepadKey)}
                      else
                        {game.overlays.add(gamepadKey)},
                    },
              );
            },
            gameOverKey: (_, RedOcelotGame game) {
              return GameOverOverlay(game: game, score: game.totalScore);
            },
          },

          initialActiveOverlays: const [mainMenuKey],
        ),
      ),
    );
  }
}
