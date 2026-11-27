import 'package:material_ui/material_ui.dart';
import 'package:pokemon/models/evolution_chain.dart';
import 'package:pokemon/models/gender_info.dart';
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
      GenderInfo gender,
      String flavorText,
      GenerationInfo generation,
      EvolutionChainInfo evolutionChain,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
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
              Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 210),
                    child: SizedBox(
                      width: double.infinity,
                      child: Material(
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
                                      GenderInfo gender,
                                      String flavorText,
                                      GenerationInfo generation,
                                      EvolutionChainInfo evolutionChain,
                                    })
                                  >(
                                    future: _speciesFuture,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 200,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }

                                      final data = snapshot.data!;
                                      final gender = data.gender;
                                      final generation = data.generation;
                                      final evolutionChain =
                                          data.evolutionChain;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 14,
                                            ),
                                            // flavor text
                                            child: Text(
                                              data.flavorText,
                                              style: textTheme.bodyLarge!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
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
                                                              generation:
                                                                  generation,
                                                            ),
                                                      ),
                                                    ),
                                              ),
                                              // gender
                                              _Stat(
                                                label: 'Gender',
                                                gender: gender,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          // evolution chain
                                          _EvolutionChain(
                                            node: evolutionChain,
                                            currentSpecies: pokemon.name,
                                            textTheme: textTheme,
                                            colorScheme: colorScheme,
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 10,
                                                color: typeColor(
                                                  pokemon.types.first,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // abilities
                                              _Stat(
                                                label: 'Abilities:',
                                                value: pokemon.displayAbilities,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 32),
                                          // stats bar
                                          Column(
                                            spacing: 16,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              for (var stat
                                                  in pokemon.stats) ...[
                                                _statBar(
                                                  pokemon,
                                                  stat,
                                                  colorScheme,
                                                  textTheme,
                                                ),
                                              ],
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 24,
                                            ),
                                            child: Divider(
                                              thickness: 0.5,
                                              color: colorScheme.outlineVariant,
                                            ),
                                          ),
                                          // media total
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 2,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          colorScheme.outline,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    evolutionChain.medianLabel(
                                                      evolutionChain,
                                                      pokemon.name,
                                                    ),
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              _Stat(
                                                label: 'Total',
                                                labelColor: colorScheme.outline,
                                                value: '${pokemon.totalStats}',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (pokemon.imageUrl != null)
                    Image.network(
                      pokemon.imageUrl!,
                      height: 240,
                      fit: BoxFit.contain,
                    )
                  else
                    Icon(Icons.catching_pokemon, size: 120),
                ],
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
            color: Theme.of(context).colorScheme.outlineVariant,
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
    this.labelColor,
    this.value,
    this.fontWeight = FontWeight.w500,
    this.pokemon,
    this.generation,
    this.gender,
    this.onTypeTap,
    this.onGenerationTap,
  });

  final String label;
  final Color? labelColor;
  final String? value;
  final FontWeight fontWeight;
  final Pokemon? pokemon;
  final GenerationInfo? generation;
  final GenderInfo? gender;
  final void Function(String)? onTypeTap;
  final VoidCallback? onGenerationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = theme.bodyLarge!.copyWith(
      color: labelColor ?? colorScheme.onSurfaceVariant,
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
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onTypeTap!(pokemon!.types[i]),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: typeColor(pokemon!.types[i]),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        typeBadgeAsset(pokemon!.types[i]),
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _LinkText(pokemon!.types[i].capitalized, style: valueStyle),
                ],
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
        // gender
        else if (gender != null)
          Tooltip(
            message: gender!.isGenderless
                ? 'Genderless'
                : gender!.femalePercentage == 0
                ? '100% male'
                : gender!.malePercentage == 0
                ? '100% female'
                : '♂ ${gender!.formatPercentage(gender!.malePercentage)}%  '
                      '♀ ${gender!.formatPercentage(gender!.femalePercentage)}%',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (gender!.isGenderless)
                  Icon(Icons.block, size: 16, color: valueStyle.color)
                else if (gender!.femalePercentage == 0)
                  Icon(Icons.male, size: 20, color: valueStyle.color)
                else if (gender!.malePercentage == 0)
                  Icon(Icons.female, size: 20, color: valueStyle.color)
                else ...[
                  Icon(Icons.male, size: 20, color: valueStyle.color),
                  Icon(Icons.female, size: 20, color: valueStyle.color),
                ],
              ],
            ),
          )
        // value text
        else
          valueText,
      ],
    );
  }
}

// link to pokemon detail screen
Widget _linkTo(
  BuildContext context,
  EvolutionChainInfo n,
  Widget child, {
  required String currentSpecies,
}) {
  if (n.species == currentSpecies) return child;

  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(idOrName: n.species),
      ),
    ),
    child: child,
  );
}

// Evolution Chain Widget
class _EvolutionChain extends StatelessWidget {
  const _EvolutionChain({
    required this.node,
    required this.currentSpecies,
    required this.textTheme,
    required this.colorScheme,
    this.imageSize = 48,
  });

  final EvolutionChainInfo node;
  final String currentSpecies;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final double imageSize;

  Widget _stage(EvolutionChainInfo n) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.network(
        n.spriteUrl,
        height: imageSize,
        width: imageSize,
        fit: BoxFit.contain,
      ),
      const SizedBox(width: 8),
      Text(
        n.displayName,
        style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final stage = _stage(node);

    // Leaf stage
    if (node.isLeaf) {
      return _linkTo(context, node, stage, currentSpecies: currentSpecies);
    }

    // Branch stage + more than one possible evolution
    if (node.isBranch) {
      final count = node.evolvesTo.length;

      bool containsSpecies(EvolutionChainInfo n, String name) {
        if (n.species == name) return true;
        return n.evolvesTo.any((c) => containsSpecies(c, name));
      }

      final branchTowardCurrent = node.evolvesTo
          .where((e) => containsSpecies(e, currentSpecies))
          .firstOrNull;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _linkTo(
                context,
                node,
                stage,
                currentSpecies: currentSpecies,
              ), // parent only

              Container(
                width: 40,
                height: 1,
                color: colorScheme.outlineVariant,
              ),
              // show only one possible evolution
              if (node.species != currentSpecies &&
                  branchTowardCurrent != null) ...[
                _EvolutionChain(
                  node: branchTowardCurrent,
                  currentSpecies: currentSpecies,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
              ],
            ],
          ),
          // show possible evolutions
          if (node.species == currentSpecies) ...[
            const SizedBox(height: 16),
            Material(
              color: cardSurface(colorScheme),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count possible evolutions',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final child in node.evolvesTo)
                          _EvolutionChain(
                            node: child,
                            currentSpecies: currentSpecies,
                            textTheme: textTheme,
                            colorScheme: colorScheme,
                            imageSize: 36,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    }

    // evolution stage + arrow + next evolution stage
    final children = <Widget>[
      _linkTo(context, node, stage, currentSpecies: currentSpecies),
    ];
    for (var n = node; !n.isLeaf && n.evolvesTo.length == 1;) {
      n = n.evolvesTo.first;
      children
        ..add(const Icon(Icons.arrow_forward, size: 20))
        ..add(_linkTo(context, n, _stage(n), currentSpecies: currentSpecies));
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: children,
    );
  }
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
