import 'package:flutter/material.dart';
import 'pokemon_detail_screen.dart';
import 'package:pokemon/services/api.dart';
import 'package:pokemon/models/pokemon_list_item.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key, required this.title});

  final String title;

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  late final Future<List<PokemonListItem>> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    _pokemonFuture = PokemonApi.getPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<PokemonListItem>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          // error
          if (snapshot.hasError) {
            return Center(child: Text('Could not load Pokémon'));
          }
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              final list = snapshot.data ?? [];
              final pokemon = list[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.network(pokemon.spriteUrl),
                  ),
                  title: Text(pokemon.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PokemonDetailScreen(pokemonName: pokemon.name),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
