import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokemon/models/pokemon_list_item.dart';
import 'package:pokemon/models/pokemon.dart';

class PokemonApi {
  static const int pageSize = 5;
  static const String host = 'pokeapi.co';

  // get pokemon list
  static Future<List<PokemonListItem>> getPokemon({
    int limit = pageSize,
    int offset = 0,
  }) async {
    final response = await http.get(
      Uri.https(host, '/api/v2/pokemon', {
        'limit': '$limit',
        'offset': '$offset',
      }),
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

  // get pokemon count
  static Future<int> getPokemonCount() async {
    final response = await http.get(
      Uri.https(host, '/api/v2/pokemon', {'limit': '1'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load pokemon count: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    return data['count'] as int;
  }

  // get all pokemons for search query
  static Future<List<PokemonListItem>> getAllPokemon() async {
    final count = await getPokemonCount();
    final pokemon = await getPokemon(limit: count);
    return pokemon;
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
