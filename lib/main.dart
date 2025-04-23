import 'package:flutter/material.dart';
import 'package:game_2048/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '2048',
      routerConfig: AppRouter.config,
    );
  }
}
