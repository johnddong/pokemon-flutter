import 'package:flutter/material.dart';
import 'package:pokemon/models/evolution_chain.dart';
import 'package:pokemon/models/generation_info.dart';
import 'package:pokemon/models/pokemon.dart';
import 'package:pokemon/models/pokemon_stat.dart';
import 'package:pokemon/screens/pokemon_generation_screen.dart';
import 'package:pokemon/screens/pokemon_type_screen.dart';
import 'package:pokemon/services/api.dart';
import 'package:pokemon/extensions/string_capitalized.dart';
import 'package:pokemon/theme/type_colors.dart';

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({super.key, required this.idOrName, this.title});

  final String idOrName;
  final String? title;

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Future<Pokemon> _pokemonFuture;
  late Future<
    ({
      String flavorText,
      GenerationInfo generation,
      List<EvolutionChainInfo> evolutionChain,
    })
  >
  _speciesFuture;

  @override
  void initState() {
    super.initState();
    _pokemonFuture = PokemonApi.getPokemonByName(widget.idOrName);
    _speciesFuture = _pokemonFuture.then(
      (pokemon) => PokemonApi.getSpecies(pokemon.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.title ?? widget.idOrName).capitalized),
      ),
      body: FutureBuilder<Pokemon>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          // back to list
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.catching_pokemon, size: 72),
                  const SizedBox(height: 16),
                  Text('Pokémon not found'),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Back to list'),
                  ),
                ],
              ),
            );
          }

          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pokemon = snapshot.data!;

          // sort stats by baseStat descending
          final textTheme = Theme.of(context).textTheme;
          final colorScheme = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pokemon.imageUrl != null)
                Center(
                  child: Image.network(
                    pokemon.imageUrl!,
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                )
              else
                Icon(Icons.catching_pokemon, size: 120),

              Material(
                color: cardSurface(colorScheme),
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              typeColor(
                                pokemon.types.first,
                              ).withValues(alpha: 0.20),
                              typeColor(
                                pokemon.types.first,
                              ).withValues(alpha: 0.06),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 36,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pokédex ${pokemon.displayId}',
                            style: textTheme.labelSmall!.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'About ${pokemon.displayName}',
                            style: textTheme.headlineLarge!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          FutureBuilder<
                            ({
                              String flavorText,
                              GenerationInfo generation,
                              List<EvolutionChainInfo> evolutionChain,
                            })
                          >(
                            future: _speciesFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final data = snapshot.data!;
                              final generation = data.generation;
                              final evolutionChain = data.evolutionChain;

                              // current index of pokemon
                              final currentIndex = evolutionChain.indexWhere(
                                (s) => s.species == pokemon.name,
                              );
                              // next index of evoluted pokemon
                              final nextIndex =
                                  (currentIndex >= 0 &&
                                      currentIndex < evolutionChain.length - 1)
                                  ? currentIndex + 1
                                  : -1;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    // flavor text
                                    child: Text(
                                      data.flavorText,
                                      style: textTheme.bodyLarge!.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // stats
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 8,
                                    children: [
                                      _Stat(
                                        label: 'Type',
                                        pokemon: pokemon,
                                        onTypeTap: (type) =>
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PokemonTypeScreen(
                                                      type: type,
                                                    ),
                                              ),
                                            ),
                                      ),
                                      _Stat(
                                        label: 'Height',
                                        value: pokemon.formateWithUnit(
                                          pokemon.height / 10,
                                          'm',
                                        ),
                                      ),
                                      _Stat(
                                        label: 'Weight',
                                        value: pokemon.formateWithUnit(
                                          pokemon.weight / 10,
                                          'kg',
                                        ),
                                      ),
                                      _Stat(
                                        label: 'Generation',
                                        generation: generation,
                                        onGenerationTap: () =>
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PokemonGenerationScreen(
                                                      generation: generation,
                                                    ),
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // evolution chain
                                  Wrap(
                                    runSpacing: 12,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      for (
                                        var i = 0;
                                        i < evolutionChain.length;
                                        i++
                                      ) ...[
                                        _evolutionChain(
                                          i,
                                          nextIndex,
                                          evolutionChain,
                                          textTheme,
                                          colorScheme,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          // strongest stat
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: typeColor(pokemon.types.first),
                              ),
                              const SizedBox(width: 8),
                              _Stat(
                                label: 'Strongest stat:',
                                value: pokemon.strongestStat.dispplayStatName,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // stats bar
                          Column(
                            spacing: 16,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var stat in pokemon.stats) ...[
                                _statBar(pokemon, stat, colorScheme, textTheme),
                              ],
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Divider(
                              thickness: 0.5,
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          // media total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _Stat(
                                label: 'Total',
                                value: '${pokemon.totalStats}',
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// show underline on link text
class _LinkText extends StatelessWidget {
  const _LinkText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 1,
          ),
        ),
      ),
      child: Text(text, style: style),
    );
  }
}

// types/weight/height/generation Widget
class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    this.value,
    this.fontWeight = FontWeight.w500,
    this.pokemon,
    this.generation,
    this.onTypeTap,
    this.onGenerationTap,
  });

  final String label;
  final String? value;
  final FontWeight fontWeight;
  final Pokemon? pokemon;
  final GenerationInfo? generation;
  final void Function(String)? onTypeTap;
  final VoidCallback? onGenerationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = theme.bodyLarge!.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    // value style without underline
    final valueStyle = theme.bodyLarge!.copyWith(
      fontWeight: fontWeight,
      color: colorScheme.onSurface,
    );
    // value text
    final valueText = value != null
        ? Text(value!, style: valueStyle)
        : const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 6),
        // type links
        if (onTypeTap != null && pokemon != null)
          for (var i = 0; i < pokemon!.types.length; i++) ...[
            // addd / between types
            if (i > 0) Text(' / ', style: valueStyle),
            GestureDetector(
              onTap: () => onTypeTap!(pokemon!.types[i]),
              child: _LinkText(
                pokemon!.types[i].capitalized,
                style: valueStyle,
              ),
            ),
          ]
        // generation link
        else if (onGenerationTap != null && generation != null)
          GestureDetector(
            onTap: () => onGenerationTap!(),
            child: _LinkText(
              'Gen ${generation!.id} · ${generation!.displayName}',
              style: valueStyle,
            ),
          )
        // value text
        else
          valueText,
      ],
    );
  }
}

// Evolution Chain Widget
Widget _evolutionChain(
  int i,
  int nextIndex,
  List<EvolutionChainInfo> evolutionChain,
  TextTheme textTheme,
  ColorScheme colorScheme,
) {
  final grayEvolutedSpecies = nextIndex > -1 && i > nextIndex;
  final grayArrow = nextIndex > -1 && i + 1 > nextIndex;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.network(
        evolutionChain[i].spriteUrl,
        height: 48,
        width: 48,
        fit: BoxFit.contain,
        color: grayEvolutedSpecies ? colorScheme.outlineVariant : null,
      ),
      const SizedBox(width: 8),
      Text(
        evolutionChain[i].displayName,
        style: textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w600,
          color: grayEvolutedSpecies
              ? colorScheme.outlineVariant
              : colorScheme.onSurface,
        ),
      ),
      if (i < evolutionChain.length - 1)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.arrow_forward,
            size: 20,
            color: grayArrow
                ? colorScheme.outlineVariant
                : colorScheme.onSurface,
          ),
        ),
    ],
  );
}

// Progress Bar Widget
Widget _statBar(
  Pokemon pokemon,
  PokemonStat stat,
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  const barHeight = 12.0;
  const maxStat = 150;
  final base = typeColor(pokemon.types.first);
  final radius = BorderRadius.circular(barHeight / 2);

  return Row(
    children: [
      SizedBox(width: 130, child: Text(stat.dispplayStatName)),
      Expanded(
        child: Container(
          height: barHeight,
          constraints: const BoxConstraints(maxWidth: 160),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: radius,
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (stat.baseStat / maxStat).clamp(0.0, 1.0),
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(base, Colors.white, 0.62)!,
                    base,
                    Color.lerp(base, Colors.black, 0.12)!,
                  ],
                  stops: [0.0, 0.50, 1.0],
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      SizedBox(
        width: 50,
        child: Text(
          '${stat.baseStat}',
          textAlign: TextAlign.right,
          style: textTheme.bodyLarge!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
