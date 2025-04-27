import 'package:flutter/material.dart';
import 'package:red_ocelot/config/game_settings.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/ui/pallette.dart';

class GameOverOverlay extends StatefulWidget {
  final RedOcelotGame game;
  final int score;

  const GameOverOverlay({required this.game, required this.score, super.key});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  List<HighScore> highScores = [];
  bool isLoading = true;
  bool showHighScores = false;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    final scores = await GameSettings().highScores;
    setState(() {
      highScores = scores;
      isLoading = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

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
              'Final Score: ${widget.score}',
              style: const TextStyle(fontSize: 24, color: textColor),
            ),
            const SizedBox(height: 10),

            if (!showHighScores)
              TextButton(
                onPressed: () => setState(() => showHighScores = true),
                child: const Text(
                  'Show High Scores',
                  style: TextStyle(color: textColorHighlight, fontSize: 16),
                ),
              )
            else if (isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'HIGH SCORES',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child:
                        highScores.isEmpty
                            ? const Center(
                              child: Text(
                                'No high scores yet!',
                                style: TextStyle(color: textColor),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: highScores.length,
                              itemBuilder: (context, index) {
                                final score = highScores[index];
                                final isNewScore =
                                    widget.score == score.score &&
                                    (DateTime.now()
                                            .difference(score.dateTime)
                                            .inSeconds <
                                        10);

                                return ListTile(
                                  dense: true,
                                  title: Row(
                                    children: [
                                      Text(
                                        '${index + 1}. ',
                                        style: TextStyle(
                                          color:
                                              isNewScore
                                                  ? textColorHighlight
                                                  : textColor,
                                          fontWeight:
                                              isNewScore
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                      Text(
                                        'Score: ${score.score}',
                                        style: TextStyle(
                                          color:
                                              isNewScore
                                                  ? textColorHighlight
                                                  : textColor,
                                          fontWeight:
                                              isNewScore
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Time: ${_formatDuration(score.time)}',
                                        style: TextStyle(
                                          color:
                                              isNewScore
                                                  ? textColorHighlight
                                                  : textColor,
                                          fontWeight:
                                              isNewScore
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => showHighScores = false),
                    child: const Text(
                      'Hide High Scores',
                      style: TextStyle(color: textColorHighlight, fontSize: 16),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.game.resetGame();
                    widget.game.startGame();
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
                  onPressed: () => widget.game.showMainMenu(),
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
