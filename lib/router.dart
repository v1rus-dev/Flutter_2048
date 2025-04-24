import 'package:flutter/material.dart';
import 'package:game_2048/game_screen/game_screen.dart';
import 'package:game_2048/home/home_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  static final config = GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: HomeScreen.path,
      routes: <RouteBase>[
        GoRoute(
          path: HomeScreen.path,
          name: HomeScreen.path,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: GameScreenPage.path,
          name: GameScreenPage.path,
          builder: (context, state) => GameScreenPage(
            countOfItemsInRow: state.extra as int,
          ),
        )
      ]);
}
