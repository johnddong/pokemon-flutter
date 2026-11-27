import 'package:pokemon/extensions/string_capitalized.dart';

class EvolutionChainInfo {
  EvolutionChainInfo({
    required this.url,
    required this.species,
    this.evolvesTo = const [],
  });

  final String species;
  final String url;
  final List<EvolutionChainInfo> evolvesTo;

  String get displayName => species.capitalized;

  // species
  int get id => int.parse(url.split('/').where((part) => part.isNotEmpty).last);
  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  // no evolution
  bool get isLeaf => evolvesTo.isEmpty;
  // more than one possible evolution
  bool get isBranch => evolvesTo.length > 1;

  // stage label: 'none' | 'first' | 'second' | 'third'
  String stageLabel(EvolutionChainInfo root, String name) {
    if (root.isLeaf) return 'none';

    int? depth(EvolutionChainInfo n, int stage) {
      if (n.species == name) return stage;
      for (final c in n.evolvesTo) {
        final d = depth(c, stage + 1);
        if (d != null) return d;
      }
      return null;
    }

    return switch (depth(root, 1)) {
      1 => 'first',
      2 => 'second',
      3 => 'third',
      _ => 'unknown',
    };
  }

  // 'Median of Pokémon that don\'t evolve' | 'Median of ${stage}-stage Pokémon'
  String medianLabel(EvolutionChainInfo root, String name) {
    if (root.isLeaf) return 'Median of Pokémon that don\'t evolve';
    return 'Median of ${stageLabel(root, name)}-stage Pokémon';
  }

  factory EvolutionChainInfo.fromChain(Map<String, dynamic> json) {
    final species = json['species'] as Map<String, dynamic>;
    final next = json['evolves_to'] as List? ?? [];
    return EvolutionChainInfo(
      species: species['name'] as String,
      url: species['url'] as String,
      evolvesTo: next
          .map((n) => EvolutionChainInfo.fromChain(n as Map<String, dynamic>))
          .toList(),
    );
  }
}
