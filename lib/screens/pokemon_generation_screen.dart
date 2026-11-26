import 'package:material_ui/material_ui.dart';
import 'package:pokemon/models/generation_info.dart';
import 'package:pokemon/services/api.dart';
import 'package:pokemon/theme/spacing.dart';
import 'package:pokemon/widgets/chip_row.dart';
import 'package:pokemon/widgets/pokemon_grid.dart';
import 'package:pokemon/widgets/section_header.dart';
import 'package:pokemon/widgets/skeletons/chipRowSkeleton.dart';

class PokemonGenerationScreen extends StatefulWidget {
  const PokemonGenerationScreen({
    super.key,
    required this.generation,
    this.generations,
  });

  final GenerationInfo generation;
  final List<GenerationInfo>? generations;

  @override
  State<PokemonGenerationScreen> createState() =>
      _PokemonGenerationScreenState();
}

class _PokemonGenerationScreenState extends State<PokemonGenerationScreen> {
  late GenerationInfo _selectedGeneration;
  late Future<List<GenerationInfo>> _generationsFuture;

  @override
  void initState() {
    super.initState();
    // selected generation
    _selectedGeneration = widget.generation;
    // generations list
    _generationsFuture = widget.generations != null
        ? Future.value(widget.generations!)
        : PokemonApi.getAllGenerations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedGeneration.generationLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Other regions
          SectionHeader(title: 'Other regions'),
          FutureBuilder<List<GenerationInfo>>(
            future: _generationsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SizedBox(
                  height: 128,
                  child: Center(child: Text('Could not load generations')),
                );
              }

              // ChipRow & SectionHeader placeholder
              if (!snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ChipRowSkeleton(),
                    SectionHeader(
                      title: '${_selectedGeneration.displayName} Pokémon',
                      subtitle: 'By Pokédex number',
                      trailing: null,
                    ),
                  ],
                );
              }

              final generations = snapshot.data!;

              return Column(
                children: [
                  ChipRow(
                    items: generations.map((g) => g.mainRegion).toList(),
                    selected: _selectedGeneration.mainRegion,
                    onSelected: (region) {
                      setState(() {
                        _selectedGeneration = generations.firstWhere(
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
                ],
              );
            },
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
