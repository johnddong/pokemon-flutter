int typeMascotId(String type) {
  return switch (type) {
    'water' => 658, // Greninja
    'normal' => 133, // Eevee
    'grass' => 1, // Bulbasaur
    'flying' => 249, // Lugia
    'psychic' => 150, // Mewtwo
    'bug' => 212, // Scizor
    'poison' => 34, // Nidoking
    'fire' => 6, // Charizard
    'ground' => 383, // Groudon
    'rock' => 248, // Tyranitar
    'fighting' => 448, // Lucario
    'dragon' => 384, // Rayquaza
    'dark' => 197, // Umbreon
    'electric' => 25, // Pikachu
    'ghost' => 94, // Gengar
    'ice' => 471, // Glaceon
    'steel' => 376, // Metagross
    'fairy' => 700, // Sylveon
    _ => 1,
  };
}

String typeMascotUrl(String type) =>
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${typeMascotId(type)}.png';
