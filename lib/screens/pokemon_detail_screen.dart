import 'package:flutter/material.dart';
import 'package:pokemon/models/pokemon.dart';
import 'package:pokemon/services/api.dart';
import 'package:pokemon/extensions/string_capitalized.dart';

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({super.key, required this.pokemonName});

  final String pokemonName;

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Future<Pokemon> _pokemonFuture;
  // 3D-like tilt
  double _tiltX = 0;
  double _tiltY = 0;

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _tiltY += details.delta.dx * 0.01;
      _tiltX -= details.delta.dy * 0.01;
      _tiltX = _tiltX.clamp(-0.5, 0.5);
      _tiltY = _tiltY.clamp(-0.8, 0.8);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _pokemonFuture = PokemonApi.getPokemonByName(widget.pokemonName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pokemonName.capitalized)),
      body: FutureBuilder<Pokemon>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          // error
          if (snapshot.hasError) {
            //return Center(child: Text('Error: ${snapshot.error}'));
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.catching_pokemon, size: 72),
                  const SizedBox(height: 16),
                  Text('Pokémon not found'),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Back to list'),
                  ),
                ],
              ),
            );
          }
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pokemon = snapshot.data!;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (pokemon.imageUrl != null)
                  // 3D-like tilt
                  GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective (the “3D” bit)
                        ..rotateX(_tiltX)
                        ..rotateY(_tiltY),
                      child: Image.network(
                        pokemon.imageUrl!,
                        height: 280,
                        width: 280,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  Icon(Icons.catching_pokemon, size: 120),
                const SizedBox(height: 16),
                // chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in pokemon.types)
                      Chip(label: Text(type.capitalized)),
                  ],
                ),
                const SizedBox(height: 16),
                // _Stat: Height/Weight
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Stat(label: 'Height', value: '${pokemon.height / 10} m'),
                    const SizedBox(width: 32),
                    _Stat(label: 'Weight', value: '${pokemon.weight / 10} kg'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Weight/Height Widget
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
