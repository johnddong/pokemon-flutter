import 'package:flutter/material.dart';
import 'package:pokemon/models/generation_info.dart';
import 'package:pokemon/theme/spacing.dart';
import 'package:pokemon/widgets/chip_row.dart';
import 'package:pokemon/widgets/pokemon_grid.dart';
import 'package:pokemon/widgets/section_header.dart';

class PokemonGenerationScreen extends StatefulWidget {
  const PokemonGenerationScreen({
    super.key,
    required this.generation,
    required this.generations,
  });

  final GenerationInfo generation;
  final List<GenerationInfo> generations;

  @override
  State<PokemonGenerationScreen> createState() =>
      _PokemonGenerationScreenState();
}

class _PokemonGenerationScreenState extends State<PokemonGenerationScreen> {
  late GenerationInfo _selectedGeneration;

  @override
  void initState() {
    super.initState();
    _selectedGeneration = widget.generation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_selectedGeneration.generationLabel)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Other regions
          SectionHeader(title: 'Other regions'),
          ChipRow(
            items: widget.generations.map((g) => g.mainRegion).toList(),
            selected: _selectedGeneration.mainRegion,
            onSelected: (region) {
              setState(() {
                _selectedGeneration = widget.generations.firstWhere(
                  (g) => g.mainRegion == region,
                );
              });
            },
          ),

          SectionHeader(
            title: 'Pokémon from ${_selectedGeneration.displayName}',
            subtitle: 'By Pokédex number',
            trailing: '${_selectedGeneration.count} Pokémon',
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
              itemCount: _selectedGeneration.pokemonSpecies.length,
              itemBuilder: (context, index) {
                return PokemonGrid(
                  pokemon: _selectedGeneration.pokemonSpecies[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
