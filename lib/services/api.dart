import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokemon/models/pokemon_list_item.dart';
import 'package:pokemon/models/pokemon.dart';

class PokemonApi {
  static const String host = 'pokeapi.co';

  // get the first 25 pokemon
  static Future<List<PokemonListItem>> getPokemon() async {
    final response = await http.get(
      Uri.https(host, '/api/v2/pokemon', {'limit': '25'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load pokemon: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    // Convert the map to a list of PokemonListItem objects
    final results = (data['results'] as List)
        .map(
          (result) => PokemonListItem.fromJson(result as Map<String, dynamic>),
        )
        .toList();

    return results;
  }

  // get a single pokemon by name
  static Future<Pokemon> getPokemonByName(String name) async {
    final response = await http.get(Uri.https(host, '/api/v2/pokemon/$name'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load pokemon: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    return Pokemon.fromJson(data);
  }
}

/**
data['results'] is a list of maps:
[
  {
    'name': 'bulbasaur',
    'url': 'https://pokeapi.co/api/v2/pokemon/1/'
  },
  {
    'name': 'ivysaur',
    'url': 'https://pokeapi.co/api/v2/pokemon/2/'
  }
]

getPokemon should return:
[
  PokemonListItem(name: bulbasaur, url: ...),
  PokemonListItem(name: ivysaur, url: ...),
]

Maps vs Objects:
Keep as Map: pokemon['name']
Convert to PokemonListItem: Pokemon.name

JSON string
  → json.decode  →  Map
  → fromJson     →  PokemonListItem  (object)
*/
