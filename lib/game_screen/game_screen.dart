import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:game_2048/2048_game/presentation/widgets/board_manager.dart';
import 'package:game_2048/2048_game/presentation/widgets/board_widget.dart';
import 'package:provider/provider.dart';

class GameScreenPage extends StatelessWidget {
  const GameScreenPage({
    super.key,
    required this.countOfItemsInRow,
  });

  final int countOfItemsInRow;
  static String path = '/game_screen';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BoardManager(
          withDelayAnimationStart: true, countTiles: countOfItemsInRow),
      child: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BoardManager boardManager;
  late ConfettiController _confettiController;
  int _currentScore = 0;
  bool canUndo = false;

  @override
  void initState() {
    super.initState();
    boardManager = context.read<BoardManager>();
    boardManager.addListener(_onBoardChanged);
    _confettiController = ConfettiController(duration: Duration(seconds: 10));
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BoardManager>().newGame();
            },
            child: const Text("Новая игра"),
          )
        ],
      ),
    );
  }

  _onBoardChanged() {
    final board = boardManager.state;

    debugPrint("Board changed! ${board.tiles.length} tiles");
    debugPrint('Your score: ${board.score}');
    setState(() {
      _currentScore = board.score;
      canUndo = boardManager.canUndo;
    });

    if (board.won || board.over) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (board.won) {
          _showDialog("Победа! 🎉", "Ты набрал 2048!");
          _confettiController.play();
        } else if (board.over) {
          _showDialog("Игра окончена 😢", "Нет доступных ходов.");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '2048 The Game',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Score:',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    '$_currentScore',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BoardWidget(),
              ),
              SizedBox(
                height: 16,
              ),
              Material(
                color: canUndo
                    ? Colors.amberAccent.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    boardManager.undo();
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Undo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 5,
                minBlastForce: 3,
                emissionFrequency: 0.1,
                numberOfParticles: 100,
                gravity: 0.2,
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    boardManager.removeListener(_onBoardChanged);
    _confettiController.dispose();
    super.dispose();
  }
}
