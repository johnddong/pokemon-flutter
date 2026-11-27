import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:pokemon/models/evolution_chain.dart';
import 'package:pokemon/models/gender_info.dart';
import 'package:pokemon/models/generation_info.dart';
import 'dart:convert';
import 'package:pokemon/models/pokemon_list_item.dart';
import 'package:pokemon/models/pokemon.dart';
import 'package:pokemon/models/type_info.dart';

class PokemonApi {
  static const int pageSize = 5;
  static const String host = 'pokeapi.co';

  // get pokemon list
  static Future<({List<PokemonListItem> items, int totalCount})> getPokemon({
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
    final items = (data['results'] as List)
        .map(
          (result) => PokemonListItem.fromJson(result as Map<String, dynamic>),
        )
        .toList();

    return (items: items, totalCount: data['count'] as int);
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
    return pokemon.items;
  }

  // get all types
  static Future<List<String>> getAllTypes() async {
    final response = await http.get(Uri.https(host, '/api/v2/type'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load types: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    const skip = ['unknown', 'shadow', 'stellar'];

    return (data['results'] as List)
        .map((result) => result['name'] as String)
        .where((name) => !skip.contains(name))
        .toList();
  }

  // get pokemon by type
  static Future<List<PokemonListItem>> getPokemonByType(String type) async {
    final response = await http.get(Uri.https(host, '/api/v2/type/$type'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load pokemon by type ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    final pokemon = data['pokemon'] as List;

    return pokemon
        .map((item) => PokemonListItem.fromJson(item['pokemon']))
        .toList();
  }

  // get pokemon count by type
  static Future<int> getPokemonCountByType(String type) async {
    final response = await http.get(Uri.https(host, '/api/v2/type/$type'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load pokemon count by type: ${response.statusCode}',
      );
    }

    final pokemon = json.decode(response.body)['pokemon'] as List;

    return pokemon.length;
  }

  // get type info list <name, count> sorted by count descending
  static Future<List<TypeInfo>> getTypeInfoList() async {
    // get all types
    final types = await PokemonApi.getAllTypes();
    // get pokemon count by each type
    final counts = await Future.wait(
      types.map(PokemonApi.getPokemonCountByType),
    );
    // 1. create a list of TypeInfo objects
    // 2. sort the list by count in descending order
    final sortedTypes = [
      for (final (index, name) in types.indexed)
        TypeInfo(name: name, count: counts[index]),
    ]..sort((a, b) => b.count.compareTo(a.count));

    return sortedTypes;
  }

  // get one generation (region name, count, species[name, url])
  static Future<GenerationInfo> getGeneration(int generationId) async {
    final response = await http.get(
      Uri.https(host, '/api/v2/generation/$generationId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load generations: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    return GenerationInfo.fromJson(data);
  }

  // get all generations 1-9 in parallel
  static Future<List<GenerationInfo>> getAllGenerations() {
    return Future.wait([
      for (var id = 1; id <= GenerationInfo.generationCount; id++)
        getGeneration(id),
    ]);
  }

  // get evolution chain
  static Future<EvolutionChainInfo> getEvolutionChain(int id) async {
    final response = await http.get(
      Uri.https(host, '/api/v2/evolution-chain/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load evolution chain: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    return EvolutionChainInfo.fromChain(data['chain'] as Map<String, dynamic>);
  }

  // get pokemon species (flavor text, generation info)
  static Future<
    ({
      GenderInfo gender,
      String flavorText,
      GenerationInfo generation,
      EvolutionChainInfo evolutionChain,
    })
  >
  getSpecies(int id) async {
    final response = await http.get(
      Uri.https(host, '/api/v2/pokemon-species/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load pokemon species: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    // gender
    final genderRate = data['gender_rate'] as int;
    final genderInfo = GenderInfo(
      isGenderless: genderRate == -1,
      malePercentage: (8 - genderRate) / 8 * 100,
      femalePercentage: genderRate / 8 * 100,
    );

    // flavor text
    final flavorTextEntries = data['flavor_text_entries'] as List;
    final english = flavorTextEntries.where(
      (entry) => (entry as Map)['language']['name'] == 'en',
    );
    final flavorText = english.last['flavor_text'] as String;

    // get the generation info
    final url = data['generation']['url'] as String;
    final generationId = int.parse(
      url.split('/').where((part) => part.isNotEmpty).last,
    );

    final generationInfo = await getGeneration(generationId);

    // get the evolution chain
    final evolutionChainUrl = data['evolution_chain']['url'] as String;
    final evolutionChainId = int.parse(
      evolutionChainUrl.split('/').where((part) => part.isNotEmpty).last,
    );

    final evolutionChainInfo = await getEvolutionChain(evolutionChainId);

    return (
      gender: genderInfo,
      flavorText: flavorText.replaceAll('\n', ' '),
      generation: generationInfo,
      evolutionChain: evolutionChainInfo,
    );
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
