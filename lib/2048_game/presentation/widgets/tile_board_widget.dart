import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_2048/2048_game/domain/entities/board.dart';
import 'package:game_2048/2048_game/presentation/widgets/tile_widget.dart';
import 'package:game_2048/colors.dart';

class TileBoardWidget extends StatelessWidget {
  final Board board;
  final double spacing;
  final int countTiles;
  final Animation<double> moveAnimation;
  final Animation<double> scaleAnimation;

  const TileBoardWidget({
    super.key,
    required this.board,
    required this.countTiles,
    required this.moveAnimation,
    required this.scaleAnimation,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = min(constraints.maxWidth, constraints.maxHeight);
      final tileSize = (size - (spacing * (countTiles + 1))) / countTiles;

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: boardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Пустые клетки
            for (int i = 0; i < countTiles * countTiles; i++)
              Positioned(
                top: _getTop(i, tileSize, spacing, countTiles),
                left: _getLeft(i, tileSize, spacing, countTiles),
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                    color: emptyTileColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

            // Активные тайлы
            for (final tile in board.tiles)
              TileWidget(
                key: ValueKey(tile.id),
                tile: tile,
                tileSize: tileSize,
                spacing: spacing,
                countTiles: countTiles,
                moveAnimation: moveAnimation,
                scaleAnimation: scaleAnimation,
              ),
          ],
        ),
      );
    });
  }

  double _getTop(int index, double size, double spacing, int countTiles) {
    final row = index ~/ countTiles;
    return row * size + spacing * (row + 1);
  }

  double _getLeft(int index, double size, double spacing, int countTiles) {
    final col = index % countTiles;
    return col * size + spacing * (col + 1);
  }
}
