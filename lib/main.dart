import 'package:flame/game.dart';
import 'package:flutter/material.dart';
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
            'MainMenu': (_, RedOceletGame game) {
              return Menu(
                game: game,
                title: 'Red Ocelot',
                items: [
                  MenuItem(
                    title: 'Start Game',
                    onTap: () {
                      game.overlays.remove('MainMenu');
                      // Start the game
                    },
                  ),
                  MenuItem(
                    title: 'Settings',
                    onTap: () {
                      // Handle settings tap
                    },
                  ),
                  MenuItem(
                    title: 'Exit',
                    onTap: () {
                      // Handle exit tap
                    },
                  ),
                ],
              );
            },
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    );
  }
}
