import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pokemon/extensions/string_capitalized.dart';
import 'package:pokemon/models/pokemon.dart';
import 'package:pokemon/models/pokemon_list_item.dart';
import 'package:pokemon/screens/pokemon_detail_screen.dart';
import 'package:pokemon/services/api.dart';
import 'package:pokemon/theme/type_colors.dart';

class PokemonGrid extends StatefulWidget {
  const PokemonGrid({super.key, required this.pokemon});
  final PokemonListItem pokemon;

  @override
  State<PokemonGrid> createState() => _PokemonGridState();
}

class _PokemonGridState extends State<PokemonGrid> {
  late Future<Pokemon> _pokemonDetailFuture;
  @override
  void initState() {
    super.initState();
    // fetch the pokemon details (pass id or name both work)
    _pokemonDetailFuture = PokemonApi.getPokemonByName('${widget.pokemon.id}');
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;
    final idLabel = '#${pokemon.id.toString().padLeft(4, '0')}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cardSurface(Theme.of(context).colorScheme),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PokemonDetailScreen(
                idOrName: '${widget.pokemon.id}',
                title: widget.pokemon.displayName,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          child: FutureBuilder<Pokemon>(
            future: _pokemonDetailFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox(height: 16);
              // glow color for image
              final glow = typeColor(snapshot.data!.types.first);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    idLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final artwork = constraints.biggest.shortestSide;
                        return Center(
                          child: SizedBox(
                            width: artwork,
                            height: artwork,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: 8,
                                    sigmaY: 8,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: glow.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ),
                                Image.network(
                                  pokemon.spriteUrl,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Center(
                    child: Text(
                      pokemon.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // circle of types
                  _TypeRow(types: snapshot.data!.types),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({required this.types});
  final List<String> types;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < types.length; i++) ...[
            if (i > 0) SizedBox(width: 10),
            Icon(Icons.circle, size: 10, color: typeColor(types[i])),
            SizedBox(width: 4),
            Text(
              types[i].capitalized,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
