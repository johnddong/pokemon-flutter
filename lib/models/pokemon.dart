import 'package:pokemon/extensions/string_capitalized.dart';
import 'package:pokemon/models/ability_info.dart';
import 'package:pokemon/models/pokemon_stat.dart';

class Pokemon {
  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.weight,
    required this.height,
    required this.abilities,
    required this.stats,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final List<String> types;
  final int weight;
  final int height;
  final List<AbilityInfo> abilities;
  final List<PokemonStat> stats;

  // Display name with first letter capitalized
  String get displayName => name.capitalized;

  // Display id with 4 digits, like #0143
  String get displayId => '#${id.toString().padLeft(4, '0')}';

  // Format value with unit, remove trailing .0
  String formateWithUnit(double value, String unit) {
    final text = value.toStringAsFixed(1);
    final formatted = text.endsWith('.0')
        ? text.substring(0, text.length - 2)
        : text;
    return '$formatted $unit';
  }

  // get the strongest stat like hp, attack, defense, etc.
  PokemonStat get strongestStat =>
      stats.reduce((a, b) => a.baseStat > b.baseStat ? a : b);

  // get abilities name
  String get displayAbilities => abilities
      .where((ability) => !ability.isHidden)
      .map((ability) => ability.displayAbility)
      .join(' / ');

  // get the total of all base stats
  int get totalStats => stats.fold(0, (sum, stat) => sum + stat.baseStat);

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>?;
    final other = sprites?['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl:
          // better quality image from official artwork
          artwork?['front_default'] as String? ??
          sprites?['front_default'] as String?,
      types: (json['types'] as List)
          .map((t) => (t as Map<String, dynamic>)['type']['name'] as String)
          .toList(),
      weight: json['weight'] as int,
      height: json['height'] as int,
      abilities: (json['abilities'] as List)
          .map((a) => AbilityInfo.fromJson(a as Map<String, dynamic>))
          .toList(),
      stats: (json['stats'] as List)
          .map((s) => PokemonStat.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
