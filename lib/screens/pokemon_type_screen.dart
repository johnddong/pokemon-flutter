import 'package:flutter/material.dart';
import 'package:pokemon/extensions/string_capitalized.dart';
import 'package:pokemon/models/pokemon_list_item.dart';
import 'package:pokemon/services/api.dart';
import 'package:pokemon/widgets/pokemon_grid.dart';
import 'package:pokemon/widgets/section_header.dart';

class PokemonTypeScreen extends StatefulWidget {
  const PokemonTypeScreen({super.key, required this.type});

  final String type;

  @override
  State<PokemonTypeScreen> createState() => _PokemonTypeScreenState();
}

class _PokemonTypeScreenState extends State<PokemonTypeScreen> {
  late Future<List<PokemonListItem>> _pokemonByTypeFuture;

  @override
  void initState() {
    super.initState();
    _pokemonByTypeFuture = PokemonApi.getPokemonByType(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('By type')),
      body: FutureBuilder<List<PokemonListItem>>(
        future: _pokemonByTypeFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load Pokémon'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pokemonByType = snapshot.data!;
          return Column(
            children: [
              SectionHeader(
                title: '${widget.type.capitalized} Pokémon',
                subtitle: 'By Pokédex number',
                trailing: '${pokemonByType.length} Pokémon',
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: pokemonByType.length,
                  itemBuilder: (context, index) {
                    return PokemonGrid(pokemon: pokemonByType[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
