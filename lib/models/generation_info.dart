import 'package:pokemon/extensions/string_capitalized.dart';
import 'package:pokemon/models/pokemon_list_item.dart';

class GenerationInfo {
  GenerationInfo({
    required this.id,
    required this.mainRegion,
    required this.count,
    required this.pokemonSpecies,
  });

  final int id;
  final String mainRegion;
  final int count;
  final List<PokemonListItem> pokemonSpecies;

  // generation count (1-9)
  static const int generationCount = 9;
  // generation label (Generation I, Generation II, etc.)
  String get generationLabel => 'Generation ${_toRoman(id)}';
  String get displayName => mainRegion.capitalized;

  factory GenerationInfo.fromJson(Map<String, dynamic> json) {
    final pokemonSpecies = json['pokemon_species'] as List;
    return GenerationInfo(
      id: json['id'] as int,
      mainRegion: json['main_region']['name'] as String,
      count: pokemonSpecies.length,
      pokemonSpecies: pokemonSpecies
          .map(
            (species) =>
                PokemonListItem.fromJson(species as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

String _toRoman(int number) {
  final romanNumerals = [
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
  ];
  return romanNumerals[number - 1];
}
