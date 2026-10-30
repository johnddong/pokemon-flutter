import 'package:pokemon/extensions/string_capitalized.dart';

class Pokemon {
  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.weight,
    required this.height,
  });

  final String name;
  final String? imageUrl;
  final List<String> types;
  final int weight;
  final int height;

  // Display name with first letter capitalized
  String get displayName => name.capitalized;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>?;
    final other = sprites?['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;

    return Pokemon(
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
    );
  }
}
