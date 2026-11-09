import 'package:flutter/material.dart';
import 'package:pokemon/models/generation_info.dart';
import 'package:pokemon/theme/spacing.dart';
import 'package:pokemon/widgets/pokemon_grid.dart';
import 'package:pokemon/widgets/section_header.dart';

class PokemonGenerationScreen extends StatelessWidget {
  const PokemonGenerationScreen({super.key, required this.generation});

  final GenerationInfo generation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(generation.generationLabel)),
      body: Column(
        children: [
          SectionHeader(
            title: 'Pokémon from ${generation.displayName}',
            subtitle: 'By Pokédex number',
            trailing: '${generation.count} Pokémon',
          ),
          SizedBox(height: AppSpacing.belowTitle),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.betweenSections,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.gridGap,
                crossAxisSpacing: AppSpacing.gridGap,
                childAspectRatio: 1,
              ),
              itemCount: generation.pokemonSpecies.length,
              itemBuilder: (context, index) {
                return PokemonGrid(pokemon: generation.pokemonSpecies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
