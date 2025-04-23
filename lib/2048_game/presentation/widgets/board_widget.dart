import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:game_2048/2048_game/presentation/widgets/board_manager.dart';
import 'package:game_2048/2048_game/presentation/widgets/tile_board_widget.dart';

class BoardWidget extends StatefulWidget {
  const BoardWidget({super.key});

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with TickerProviderStateMixin {
  late final AnimationController _moveController;
  late final AnimationController _scaleController;
  late final CurvedAnimation _moveAnimation;
  late final CurvedAnimation _scaleAnimation;

  final Duration _moveAnimateDuration = const Duration(milliseconds: 360);

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      duration: _moveAnimateDuration,
      vsync: this,
    );

    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOutCubic, // ✅ плавное перемещение
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut, // ✅ "выпрыгивание" при объединении
    );

    // ✅ Запускаем scale-анимацию после первой отрисовки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleSwipe(SwipeDirection direction, Offset offset) {
    final manager = context.read<BoardManager>();
    if (manager.isMoving || manager.state.over || manager.state.won) return;

    final moved = manager.move(direction);
    if (moved) {
      _moveController.forward(from: 0);
      manager.merge();
      _scaleController.forward(from: 0);
      Future.delayed(_moveAnimateDuration, () {
        manager.endMove();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardManager = context.watch<BoardManager>();
    final board = boardManager.state;

    return SwipeDetector(
      onSwipe: _handleSwipe,
      child: TileBoardWidget(
        board: board,
        countTiles: boardManager.countTiles,
        moveAnimation: _moveAnimation,
        scaleAnimation: _scaleAnimation,
      ),
    );
  }
}
