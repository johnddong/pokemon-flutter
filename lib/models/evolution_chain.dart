import 'package:pokemon/extensions/string_capitalized.dart';

class EvolutionChainInfo {
  final String species;
  final String url;

  EvolutionChainInfo({required this.url, required this.species});

  String get displayName => species.capitalized;

  // species
  int get id => int.parse(url.split('/').where((part) => part.isNotEmpty).last);
  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  factory EvolutionChainInfo.fromSpecies(Map<String, dynamic> json) {
    return EvolutionChainInfo(
      species: json['name'] as String,
      url: json['url'] as String,
    );
  }

  static List<EvolutionChainInfo> flattenEvolutionChain(
    Map<String, dynamic> chain,
  ) {
    final flattenedSpecies = [
      EvolutionChainInfo.fromSpecies(chain['species'] as Map<String, dynamic>),
    ];

    final evolvesTo = chain['evolves_to'] as List;

    if (evolvesTo.isEmpty) return flattenedSpecies;

    var result = flattenedSpecies;
    for (final node in evolvesTo) {
      result = [
        ...result,
        ...flattenEvolutionChain(node as Map<String, dynamic>),
      ];
    }

    return result;
  }
}
