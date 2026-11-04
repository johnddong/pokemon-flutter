import 'package:flutter/material.dart';
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
  final List<PokemonListItem> _pokemon = [];
  static const int _pageSize = 10;
  int _offset = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

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

  // load all pokémon names for search query
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
    _loadMore();
    _loadNames();
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
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final pokemon = _pokemon[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.network(pokemon.spriteUrl),
                  ),
                  title: Text(pokemon.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PokemonDetailScreen(pokemonName: pokemon.name),
                      ),
                    );
                  },
                ),
              );
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
