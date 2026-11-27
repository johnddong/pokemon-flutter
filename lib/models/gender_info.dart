class GenderInfo {
  GenderInfo({
    required this.isGenderless,
    required this.malePercentage,
    required this.femalePercentage,
  });

  final bool isGenderless;
  final double malePercentage;
  final double femalePercentage;

  // format percentage
  String formatPercentage(double p) =>
      p == p.roundToDouble() ? '${p.toInt()}' : p.toStringAsFixed(1);
}
