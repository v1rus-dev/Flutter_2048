import 'package:flutter/material.dart';
import 'package:game_2048/2048_game/presentation/widgets/board_manager.dart';
import 'package:game_2048/2048_game/presentation/widgets/board_widget.dart';
import 'package:provider/provider.dart';

class GameScreenPage extends StatelessWidget {
  const GameScreenPage({super.key});

  static String path = '/game_screen';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BoardManager(withDelayAnimationStart: true, countTiles: 4),
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

  @override
  void initState() {
    super.initState();
    boardManager = context.read<BoardManager>();
    boardManager.addListener(_onBoardChanged);
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (board.won) {
        _showDialog("Победа! 🎉", "Ты набрал 2048!");
      } else if (board.over) {
        _showDialog("Игра окончена 😢", "Нет доступных ходов.");
      }
    });
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
      body: Column(
        children: [
          SizedBox(
            height: 150,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BoardWidget(),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    boardManager.removeListener(_onBoardChanged);
    super.dispose();
  }
}
