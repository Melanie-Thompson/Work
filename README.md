# 3D Game with Flutter & three_dart

A 3D mobile game built with Flutter and three_dart (Dart port of Three.js).

## Features

- 3D graphics rendering using three_dart
- Rotating cube demo scene
- Ready for game development expansion

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode for mobile deployment

## Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run the App

For development:
```bash
flutter run
```

For specific platforms:
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web (experimental)
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart              # App entry point
└── screens/
    └── game_screen.dart   # Main 3D game screen
```

## How It Works

The app uses `three_dart` and `flutter_gl` to render 3D graphics:

1. **FlutterGlPlugin**: Initializes the OpenGL context
2. **Scene**: Contains all 3D objects (cube, lights, camera)
3. **Renderer**: Renders the scene to a texture
4. **Animation Loop**: Updates and renders at ~60 FPS

## Expanding the Game

To add more game features:

1. **Add Game Objects**: Create more meshes in `setupScene()`
2. **User Input**: Add gesture detectors for touch controls
3. **Game Logic**: Implement in the `animate()` method
4. **Assets**: Load 3D models using GLTFLoader from three_dart_jsm
5. **Physics**: Add collision detection and physics

## Example: Adding More Objects

```dart
// In setupScene() method
final sphereGeometry = three.SphereGeometry(0.5, 32, 32);
final sphereMaterial = three.MeshStandardMaterial({"color": 0xff0000});
final sphere = three.Mesh(sphereGeometry, sphereMaterial);
sphere.position.set(2, 0, 0);
scene!.add(sphere);
```

## Troubleshooting

### Black screen or no rendering
- Ensure you pressed the play button to initialize the scene
- Check that flutter_gl plugin is properly initialized
- Verify GPU is available on your device

### Performance issues
- Reduce polygon count of 3D models
- Optimize texture sizes
- Use Level of Detail (LOD) techniques

## Resources

- [three_dart Documentation](https://pub.dev/packages/three_dart)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Three.js Documentation](https://threejs.org/docs/) (for reference)

## License

This project is open source and available under the MIT License.
