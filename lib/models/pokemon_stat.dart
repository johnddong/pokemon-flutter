class PokemonStat {
  PokemonStat({required this.baseStat, required this.name});

  final int baseStat;
  final String name;

  // stat name abbreviation
  String get dispplayStatName =>
      {
        'hp': 'HP',
        'attack': 'Attack',
        'defense': 'Defense',
        'special-attack': 'Sp. Atk',
        'special-defense': 'Sp. Def',
        'speed': 'Speed',
      }[name.toLowerCase()] ??
      name.toUpperCase();

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    final stat = json['stat'] as Map<String, dynamic>;
    return PokemonStat(
      baseStat: json['base_stat'] as int,
      name: stat['name'] as String,
    );
  }
}
