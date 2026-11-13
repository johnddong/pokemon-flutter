import 'package:flutter/material.dart';
import 'screens/pokemon_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    // check if the operating system is in light mode
    final osLight =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.light;
    _themeMode = osLight ? ThemeMode.light : ThemeMode.dark;
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Colors.deepPurple;

    return MaterialApp(
      title: 'Pokédex APP',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: PokemonListScreen(title: 'Pokédex', onToggleTheme: _toggleTheme),
    );
  }
}
