import 'package:flutter/material.dart';
import 'package:red_ocelot/config/game_settings.dart';
import 'package:red_ocelot/config/keys.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/ui/pallette.dart';

class HighScoresScreen extends StatefulWidget {
  final RedOcelotGame game;

  const HighScoresScreen({required this.game, super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  List<HighScore> highScores = [];
  bool isLoading = true;
  bool sortByScores = true;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    final scores = await GameSettings().highScores;

    setState(() {
      highScores = scores;
      _sortScores();
      isLoading = false;
    });
  }

  void _sortScores() {
    if (sortByScores) {
      highScores.sortByScore();
    } else {
      highScores.sortByTime();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.year == now.year) {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: backgroundColorSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'HIGH SCORES',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),

            // Sort controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sort by:', style: TextStyle(color: textColor)),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      sortByScores = true;
                      _sortScores();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        sortByScores ? primaryColor : Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  child: const Text('Score'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      sortByScores = false;
                      _sortScores();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !sortByScores ? primaryColor : Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  child: const Text('Time'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: backgroundColorSecondary,
                            title: const Text(
                              'Clear High Scores?',
                              style: TextStyle(color: textColor),
                            ),
                            content: const Text(
                              'This action cannot be undone.',
                              style: TextStyle(color: textColor),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: textColorHighlight),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      await GameSettings().clearHighScores();
                      if (mounted) {
                        _loadHighScores();
                      }
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Clear High Scores',
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Header row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(50),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 50,
                    child: Text(
                      'Rank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Score',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // High score list
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : highScores.isEmpty
                      ? const Center(
                        child: Text(
                          'No high scores recorded yet!',
                          style: TextStyle(color: textColor, fontSize: 18),
                        ),
                      )
                      : ListView.builder(
                        itemCount: highScores.length,
                        itemBuilder: (context, index) {
                          final score = highScores[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  index % 2 == 0
                                      ? Colors.black12
                                      : Colors.black26,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          index < 3
                                              ? [
                                                textColorHighlight,
                                                Colors.amber,
                                                const Color.fromARGB(
                                                  255,
                                                  180,
                                                  180,
                                                  180,
                                                ),
                                              ][index]
                                              : textColor,
                                      fontWeight:
                                          index < 3
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    score.score.toString(),
                                    style: const TextStyle(color: textColor),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _formatDuration(score.time),
                                  style: const TextStyle(color: textColor),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  _formatDate(score.dateTime),
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),

            const SizedBox(height: 10),

            // Back button
            TextButton.icon(
              onPressed: () {
                widget.game.overlays.remove(highScoresKey);
              },
              icon: const Icon(Icons.arrow_back, color: textColor),
              label: const Text(
                'Back',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
