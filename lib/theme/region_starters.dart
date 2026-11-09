// Returns the IDs of the starter Pokémon for a given generation.
List<int> regionStarterId(int generationId) {
  return switch (generationId) {
    1 => [1, 4, 7], // Bulbasaur, Charmander, Squirtle
    2 => [152, 155, 158], // Chikorita, Cyndaquil, Totodile
    3 => [252, 255, 258], // Treecko, Torchic, Mudkip
    4 => [387, 390, 393], // Turtwig, Chimchar, Piplup
    5 => [495, 498, 501], // Snivy, Tepig, Oshawott
    6 => [650, 653, 656], // Chespin, Fennekin, Froakie
    7 => [722, 725, 728], // Rowlet, Litten, Popplio
    8 => [810, 813, 816], // Grookey, Scorbunny, Sobble
    9 => [906, 909, 912], // Sprigatito, Fuecoco, Quaxly
    _ => const [],
  };
}

String starterSpriteUrl(int id) =>
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
