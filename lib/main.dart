import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/config/keys.dart';
import 'package:red_ocelot/red_ocelet_game.dart';
import 'package:red_ocelot/ui/menu.dart';
import 'package:red_ocelot/ui/pallette.dart';

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
  late RedOceletGame game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: GameWidget.controlled(
          gameFactory: RedOceletGame.new,
          overlayBuilderMap: {
            mainMenuKey: (_, RedOceletGame game) {
              return Menu(
                game: game,
                title: 'Red Ocelot',
                items: [
                  MenuItem(
                    title: 'Start Game',
                    onPressed: () {
                      game.overlays.remove(mainMenuKey);
                      // Start the game
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
                    },
                  ),
                ],
              );
            },
            settingsMenuKey: (_, RedOceletGame game) {
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
          },
          initialActiveOverlays: const [mainMenuKey],
        ),
      ),
    );
  }
}
