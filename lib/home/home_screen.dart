import 'package:flutter/material.dart';
import 'package:game_2048/game_screen/game_screen.dart';
import 'package:game_2048/router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String path = '/home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentSliverValue = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              AppRouter.config.pushNamed(GameScreenPage.path, extra: _currentSliverValue);
            },
            child: Text('Open the game'),
          ),
          SizedBox(
            height: 20,
          ),
          Text('Count of tile in row: $_currentSliverValue'),
          SizedBox(
            height: 8,
          ),
          Slider(
            min: 4,
            value: _currentSliverValue.toDouble(),
            max: 10,
            onChanged: (value) {
              debugPrint('New value: $value;');
              setState(() {
                _currentSliverValue = value.toInt();
              });
            },
          )
        ],
      ),
    );
  }
}
