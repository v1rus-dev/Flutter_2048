import 'package:flutter/material.dart';
import 'package:game_2048/2048_game/domain/entities/tile.dart';
import 'package:game_2048/colors.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;
  final double tileSize;
  final double spacing;
  final int countTiles;
  final Animation<double> moveAnimation;
  final Animation<double> scaleAnimation;

  const TileWidget({
    super.key,
    required this.tile,
    required this.tileSize,
    required this.spacing,
    required this.countTiles,
    required this.moveAnimation,
    required this.scaleAnimation,
  });

  double _getTop(int index) {
    final row = index ~/ countTiles;
    return row * tileSize + spacing * (row + 1);
  }

  double _getLeft(int index) {
    final col = index % countTiles;
    return col * tileSize + spacing * (col + 1);
  }

  @override
  Widget build(BuildContext context) {
    final top = _getTop(tile.index);
    final left = _getLeft(tile.index);

    final positioned = AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            top: top,
            left: left,
            child: _buildContent(),
          );

    return positioned;
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        final scale = tile.merged || tile.isNew ? scaleAnimation.value : 1.0;
        return Opacity(
          opacity: tile.isNew ? scaleAnimation.value : 1.0,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Container(
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          color: tileColors[tile.value],
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Center(
          child: Text(
            '${tile.value}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
              color: tile.value < 8 ? textColor : textColorWhite,
            ),
          ),
        ),
      ),
    );
  }
}
