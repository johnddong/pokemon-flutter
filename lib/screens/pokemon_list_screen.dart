import 'package:flutter/material.dart';
import 'pokemon_detail_screen.dart';
import 'package:pokemon/services/api.dart';
import 'package:pokemon/models/pokemon_list_item.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key, required this.title});

  final String title;

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final List<PokemonListItem> _pokemon = [];
  static const int _pageSize = 3;
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
                    ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: body,
    );
  }
}
