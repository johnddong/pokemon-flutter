import 'package:flutter/material.dart';
import 'package:pokemon/extensions/string_capitalized.dart';
import 'package:pokemon/models/pokemon_list_item.dart';
import 'package:pokemon/models/type_info.dart';
import 'package:pokemon/services/api.dart';
import 'package:pokemon/theme/spacing.dart';
import 'package:pokemon/theme/type_colors.dart';
import 'package:pokemon/widgets/pokemon_grid.dart';
import 'package:pokemon/widgets/section_header.dart';
import 'package:pokemon/widgets/chip_row.dart';

class PokemonTypeScreen extends StatefulWidget {
  const PokemonTypeScreen({
    super.key,
    required this.type,
    required this.typeInfo,
  });

  final String type;
  final List<TypeInfo> typeInfo;

  @override
  State<PokemonTypeScreen> createState() => _PokemonTypeScreenState();
}

class _PokemonTypeScreenState extends State<PokemonTypeScreen> {
  late String _selectedType;
  late Future<List<PokemonListItem>> _pokemonByTypeFuture;

  @override
  void initState() {
    super.initState();
    // selected chip
    _selectedType = widget.type;
    _pokemonByTypeFuture = PokemonApi.getPokemonByType(_selectedType);
  }

  @override
  Widget build(BuildContext context) {
    // selected type count
    final selectedTypeCount = widget.typeInfo
        .firstWhere((type) => type.name == _selectedType)
        .count;

    return Scaffold(
      appBar: AppBar(title: Text('By type')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Other types
          SectionHeader(title: 'Other types'),
          ChipRow(
            items: widget.typeInfo.map((type) => type.name).toList(),
            selected: _selectedType,
            onSelected: (type) {
              setState(() {
                _selectedType = type;
                _pokemonByTypeFuture = PokemonApi.getPokemonByType(type);
              });
            },
            colorOf: typeColor,
          ),
          SectionHeader(
            title: '${_selectedType.capitalized} Pokémon',
            subtitle: 'By Pokédex number',
            trailing: '$selectedTypeCount Pokémon',
          ),
          SizedBox(height: AppSpacing.belowTitle),
          Expanded(
            child: FutureBuilder<List<PokemonListItem>>(
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
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          0,
                          AppSpacing.screen,
                          AppSpacing.betweenSections,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: AppSpacing.gridGap,
                              crossAxisSpacing: AppSpacing.gridGap,
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
          ),
        ],
      ),
    );
  }
}
