import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:game_2048/2048_game/domain/entities/board.dart';
import 'package:game_2048/2048_game/domain/entities/tile.dart';
import 'package:uuid/uuid.dart';

class BoardManager extends ChangeNotifier {
  final int countTiles;
  bool _isMoving = false;
  bool get isMoving => _isMoving;

  late final List<int> horizontalLeftOrder;
  late final List<int> horizontalRightOrder;
  late final List<int> verticalUpOrder;
  late final List<int> verticalDownOrder;

  Board _state = Board.newGame(0, []);
  Board get state => _state;

  BoardManager({this.countTiles = 4, bool withDelayAnimationStart = false}) {
    horizontalLeftOrder = generateRowOrder(countTiles);
    horizontalRightOrder = List.from(horizontalLeftOrder.reversed);
    verticalUpOrder = generateColumnOrder(countTiles);
    verticalDownOrder = List.from(verticalUpOrder.reversed);

    if (withDelayAnimationStart) {
      newGameWithDelayedSecondTile();
    } else {
      newGame();
    }
  }

  void newGameWithDelayedSecondTile() {
    final first = random([]);
    _state = Board.newGame(_state.best + _state.score, [first]);
    notifyListeners();

    // Через небольшую паузу добавим вторую
    Future.delayed(const Duration(milliseconds: 500), () {
      final second = random([first.index]);
      _state = _state.copyWith(
        tiles: [..._state.tiles, second],
      );
      notifyListeners();
    });
  }

  void newGame() {
    _state = _newGame();
    debugPrint('State: ${_state.tiles}');
    notifyListeners();
  }

  Board _newGame() {
    final first = random([]);
    final second = random([first.index]); // исключаем уже занятое место

    return Board.newGame(
      _state.best + _state.score,
      [first, second], // ✅ передаём два тайла
    );
  }

  bool move(SwipeDirection direction) {
    if (_isMoving || _state.over || _state.won) return false;

    _isMoving = true;

    final order = _getOrder(direction);
    final sortedTiles = List<Tile>.from(_state.tiles)
      ..sort(
          (a, b) => order.indexOf(a.index).compareTo(order.indexOf(b.index)));

    final horizontal =
        direction == SwipeDirection.left || direction == SwipeDirection.right;
    final asc =
        direction == SwipeDirection.left || direction == SwipeDirection.up;

    List<Tile> newTiles = [];

    for (int i = 0; i < sortedTiles.length; i++) {
      var tile = sortedTiles[i];
      tile = _calculate(tile, newTiles, direction);
      newTiles.add(tile);

      if (i + 1 < sortedTiles.length) {
        var next = sortedTiles[i + 1];
        if (tile.value == next.value) {
          if (_inSameLine(tile.index, next.index, horizontal)) {
            newTiles.add(next.copyWith(nextIndex: tile.nextIndex));
            i++; // пропускаем объединённый
          }
        }
      }
    }

    _state = _state.copyWith(tiles: newTiles, undo: _state);
    notifyListeners();
    return true;
  }

  void endMove() {
    _isMoving = false;
  }

  void merge() {
    List<Tile> tiles = [];
    bool tilesMoved = false;
    List<int> occupiedIndexes = [];
    int score = _state.score;

    final original = _state.tiles;

    for (int i = 0; i < original.length; i++) {
      var tile = original[i];
      int value = tile.value;
      bool merged = false;

      if (i + 1 < original.length) {
        var next = original[i + 1];

        bool sameNextIndex = tile.nextIndex != null &&
            (tile.nextIndex == next.nextIndex ||
                tile.index == next.nextIndex && tile.nextIndex == null);

        if (sameNextIndex && tile.value == next.value) {
          // Объединяем тайлы
          value = tile.value + next.value;
          merged = true;
          score += tile.value;
          i++; // пропускаем следующий, он объединён
        }
      }

      // Было ли движение или объединение
      if (merged || tile.nextIndex != null && tile.index != tile.nextIndex) {
        tilesMoved = true;
      }

      final newIndex = tile.nextIndex ?? tile.index;

      tiles.add(tile.copyWith(
          index: newIndex,
          nextIndex: null,
          value: value,
          merged: merged,
          isNew: false));

      occupiedIndexes.add(newIndex);
    }

    // Добавим новый тайл, если был хоть один сдвиг или объединение
    if (tilesMoved) {
      tiles.add(random(occupiedIndexes));
    }

    _state = _state.copyWith(
      tiles: tiles,
      score: score,
      undo: _state,
    );

    notifyListeners();

    _endRound();
  }

  Tile random(List<int> occupiedIndexes) {
    final rng = Random();
    int i;
    do {
      i = rng.nextInt(countTiles * countTiles);
    } while (occupiedIndexes.contains(i));

    return Tile(const Uuid().v4(), 2, i, isNew: true);
  }

  Tile _calculate(Tile tile, List<Tile> tiles, SwipeDirection direction) {
    final index = tile.index;
    final horizontal =
        direction == SwipeDirection.left || direction == SwipeDirection.right;
    final asc =
        direction == SwipeDirection.left || direction == SwipeDirection.up;

    int row = index ~/ countTiles;
    int col = index % countTiles;

    int nextIndex;

    if (horizontal) {
      nextIndex = asc ? row * countTiles : (row + 1) * countTiles - 1;
    } else {
      nextIndex = asc ? col : (countTiles - 1) * countTiles + col;
    }

    if (tiles.isNotEmpty) {
      var last = tiles.last;
      var lastIndex = last.nextIndex ?? last.index;
      if (_inSameLine(index, lastIndex, horizontal)) {
        nextIndex = lastIndex + (asc ? 1 : -1) * (horizontal ? 1 : countTiles);
      }
    }

    return tile.copyWith(nextIndex: nextIndex);
  }

  void _endRound() {
    bool gameOver = true;
    bool gameWon = false;
    List<Tile> tiles = [];

    final totalTiles = countTiles * countTiles;
    final original = List<Tile>.from(_state.tiles)
      ..sort((a, b) => a.index.compareTo(b.index));

    if (original.length == totalTiles) {
      for (int i = 0; i < original.length; i++) {
        final tile = original[i];
        final value = tile.value;

        if (value == 2048) gameWon = true;

        int row = i ~/ countTiles;
        int col = i % countTiles;

        // Check left
        if (col > 0 && original[i - 1].value == value) gameOver = false;

        // Check right
        if (col < countTiles - 1 && original[i + 1].value == value)
          gameOver = false;

        // Check top
        if (row > 0 && original[i - countTiles].value == value)
          gameOver = false;

        // Check bottom
        if (row < countTiles - 1 &&
            i + countTiles < original.length &&
            original[i + countTiles].value == value) {
          gameOver = false;
        }

        tiles.add(tile.copyWith(merged: false));
      }
    } else {
      // Есть свободные клетки — игра продолжается
      gameOver = false;
      for (final tile in original) {
        if (tile.value == 2048) gameWon = true;
        tiles.add(tile.copyWith(merged: false));
      }
    }

    _state = _state.copyWith(
      tiles: tiles,
      won: gameWon,
      over: gameOver,
    );

    notifyListeners();
  }

  bool _inSameLine(int index1, int index2, bool horizontal) {
    return horizontal
        ? index1 ~/ countTiles == index2 ~/ countTiles
        : index1 % countTiles == index2 % countTiles;
  }

  List<int> _getOrder(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.left:
        return horizontalLeftOrder;
      case SwipeDirection.right:
        return horizontalRightOrder;
      case SwipeDirection.up:
        return verticalUpOrder;
      case SwipeDirection.down:
        return verticalDownOrder;
      default:
        return horizontalLeftOrder;
    }
  }

  // Генерация порядка по строкам (слева направо)
  List<int> generateRowOrder(int size) {
    List<int> result = [];
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        result.add(row * size + col);
      }
    }
    return result;
  }

  // Генерация порядка по колонкам (сверху вниз)
  List<int> generateColumnOrder(int size) {
    List<int> result = [];
    for (int col = 0; col < size; col++) {
      for (int row = 0; row < size; row++) {
        result.add(row * size + col);
      }
    }
    return result;
  }
}
