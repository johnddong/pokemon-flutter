import 'package:flutter/material.dart';
import 'package:pokemon/models/pokemon_list_item.dart';
import 'package:pokemon/screens/pokemon_detail_screen.dart';

class PokemonTile extends StatelessWidget {
  const PokemonTile({super.key, required this.pokemon});
  final PokemonListItem pokemon;

  @override
  Widget build(BuildContext context) {
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
  }
}
