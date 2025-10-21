class LevelSettings {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double minRotation;
  final double maxRotation;

  const LevelSettings({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.minRotation,
    required this.maxRotation,
  });

  // Default level settings
  static const LevelSettings level1 = LevelSettings(
    minX: -0.01,
    maxX: 0.01,
    minY: 0,
    maxY: 30,
    minRotation: 0, // ~-90 degrees in radians
    maxRotation: 30,  // ~90 degrees in radians
  );
}
