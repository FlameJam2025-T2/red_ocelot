import 'package:flutter/material.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/ui/pallette.dart';

class GameOverOverlay extends StatelessWidget {
  final RedOcelotGame game;
  final int score;

  const GameOverOverlay({Key? key, required this.game, required this.score})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColorSecondary.withAlpha(128),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: $score',
              style: const TextStyle(fontSize: 24, color: textColor),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                game.resetGame();
                game.startGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text('Play Again', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => game.showMainMenu(),
              style: TextButton.styleFrom(foregroundColor: textColor),
              child: const Text('Main Menu', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
