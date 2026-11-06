import 'package:flutter/material.dart';
import 'package:pokemon/extensions/string_capitalized.dart';
import 'package:pokemon/models/type_info.dart';
import 'package:pokemon/screens/pokemon_type_screen.dart';
import 'package:pokemon/theme/type_colors.dart';
import 'package:pokemon/theme/type_mascots.dart';
import 'package:pokemon/widgets/pokemon_tile.dart';
import 'package:pokemon/widgets/section_header.dart';
import 'pokemon_detail_screen.dart';
import 'package:pokemon/services/api.dart';
import 'package:pokemon/models/pokemon_list_item.dart';
import 'package:pokemon/widgets/search_field.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key, required this.title});

  final String title;

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  // search
  void _search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(pokemonName: q),
      ),
    );
  }

  // load all types
  List<TypeInfo> _types = [];
  Future<void> _loadTypes() async {
    try {
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

      setState(() {
        _types = sortedTypes;
      });
    } catch (_) {}
  }

  // search query
  List<PokemonListItem> _catalog = [];
  Future<void> _loadNames() async {
    try {
      final catalog = await PokemonApi.getAllPokemon();
      setState(() {
        _catalog = catalog;
      });
    } catch (_) {}
  }

  // load more pokémon
  final List<PokemonListItem> _pokemon = [];
  static const int _pageSize = 10;
  int _offset = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await PokemonApi.getPokemon(
        limit: _pageSize,
        offset: _offset,
      );
      setState(() {
        _pokemon.addAll(page);
        _offset += page.length;
        _hasMore = page.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTypes();
    _loadNames();
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_pokemon.isEmpty && _isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null && _pokemon.isEmpty) {
      body = Center(child: Text('Could not load Pokémon'));
    } else {
      // list of pokemon
      body = CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'By type',
              subtitle: '${_types.length} types',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.8,
              children: [
                for (final type in _types)
                  Material(
                    color: Color.lerp(typeColor(type.name), Colors.white, 0.82),
                    elevation: 0,
                    shadowColor: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                PokemonTypeScreen(type: type.name),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.name.capitalized,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                                Text(
                                  '${type.count} Pokémon',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 0,
                            child: Image.network(
                              typeMascotUrl(type.name),
                              width: 88,
                              height: 88,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final pokemon = _pokemon[index];
              return PokemonTile(pokemon: pokemon);
            }, childCount: _pokemon.length),
          ),
          // Load more button
          if (_hasMore)
            SliverToBoxAdapter(
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : TextButton.icon(
                      label: Text(
                        'Load more',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onPressed: _loadMore,
                      icon: const Icon(Icons.arrow_downward),
                      iconAlignment: IconAlignment.end,
                    ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        // search autocomplete
        title: SearchField(catalog: _catalog, onSearch: _search),
      ),
      body: body,
    );
  }
}
