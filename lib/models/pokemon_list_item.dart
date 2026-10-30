import 'package:pokemon/extensions/string_capitalized.dart';

class PokemonListItem {
  PokemonListItem({required this.name, required this.url});

  final String name;
  final String url;

  // capitalize the first letter of the string
  String get displayName => name.capitalized;

  // get the id from the url
  int get id => int.parse(url.split('/').where((s) => s.isNotEmpty).last);
  // pass the id to the sprite url
  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  //fromJson reads the map and returns a new object.
  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
