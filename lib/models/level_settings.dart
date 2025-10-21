class LevelSettings {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double minRotation;
  final double maxRotation;
  final double brightness;
  final String event;
  final double startPositionX;
  final double startRotationX;

  const LevelSettings({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.minRotation,
    required this.maxRotation,
    required this.brightness,
    required this.event,
    required this.startPositionX,
    required this.startRotationX,
  });

  // Array of level settings
  static const List<LevelSettings> levels = [
    // Level 0
    LevelSettings(
      minX: -0.01,
      maxX: 0.01,
      minY: 0,
      maxY: 30,
      minRotation: 0,
      maxRotation: 30,
      brightness: 0.2,
      event: 'wiggle',
      startPositionX: 0.0,
      startRotationX: 0.0,
    ),
    // Level 1
    LevelSettings(
      minX: -0.1,
      maxX: 0.01,
      minY: 0,
      maxY: 30,
      minRotation: 0,
      maxRotation: 30,
      brightness: 0.5,
      event: 'wiggle',
      startPositionX: 0.0,
      startRotationX: 0.0,
    ),
    // Level 2
    LevelSettings(
      minX: -0.1,
      maxX: 0.13,
      minY: 0,
      maxY: 30,
      minRotation: 0,
      maxRotation: 30,
      brightness: 1,
      event: 'rotation',
      startPositionX: 0.0,
      startRotationX: 0.0,
    ),
    // Level 3
    LevelSettings(
      minX: -0.1,
      maxX: 0.13,
      minY: 0,
      maxY: 30,
      minRotation: 0,
      maxRotation: 30,
      brightness: 2,
      event: 'none',
      startPositionX: 0,
      startRotationX: 1,
    ),
  ];
}
