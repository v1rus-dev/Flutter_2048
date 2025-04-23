import 'package:flutter/material.dart';
import 'package:game_2048/game_screen/game_screen.dart';
import 'package:game_2048/router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String path = '/home_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
            onPressed: () {
              AppRouter.config.pushNamed(GameScreenPage.path);
            },
            child: Text('Open the game')),
      ),
    );
  }
}
