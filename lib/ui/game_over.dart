import 'package:flutter/material.dart';
import 'package:red_ocelot/config/game_settings.dart';
import 'package:red_ocelot/config/keys.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/ui/pallette.dart';

class GameOverOverlay extends StatelessWidget {
  final RedOcelotGame game;
  final int score;

  const GameOverOverlay({required this.game, required this.score, super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColorSecondary.withAlpha(220),
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
            const SizedBox(height: 10),

            TextButton(
              onPressed: () => game.overlays.add(highScoresKey),
              child: const Text(
                'Show High Scores',
                style: TextStyle(color: textColorHighlight, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    game.resetGame();
                    game.startGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => game.showMainMenu(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Main Menu',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
