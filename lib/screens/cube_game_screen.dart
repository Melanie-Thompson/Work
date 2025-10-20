import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'dart:math' as math;

class CubeGameScreen extends StatefulWidget {
  const CubeGameScreen({super.key});

  @override
  State<CubeGameScreen> createState() => _CubeGameScreenState();
}

class _CubeGameScreenState extends State<CubeGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Cube(
        onSceneCreated: (Scene scene) {
          // Add machine
          final machine = Object(
            fileName: 'assets/models/machine_converted.obj',
          );
          machine.lighting = true;
          scene.world.add(machine);

          // Add dial on top of machine
          final dial = Object(
            fileName: 'assets/models/floor_dial_converted.obj',
          );
          dial.lighting = false;
          
          // Position centered on the top face of the machine
          dial.position.setValues(0, 3.1, 0.52);
          
          // Fixed rotation - no skew
          dial.rotation.setValues(-math.pi / 2, 0, 0);
          
          // Scale to fit nicely on the machine
          dial.scale.setValues(0.35, 0.35, 0.35);
          
          dial.updateTransform();
          scene.world.add(dial);

          // Add simple lever in the center
          final lever = Object(
            fileName: 'assets/models/simple_lever.obj',
          );
          lever.lighting = true;
          lever.position.setValues(0, 0, 0); // Center position
          lever.scale.setValues(0.5, 0.5, 0.5);
          lever.updateTransform();
          scene.world.add(lever);

          // Brighter lighting
          scene.light.position.setValues(0, 50, 50);
          
          // Back to original camera view
          scene.camera.zoom = 12;
          scene.camera.position.setValues(0, 12, 3);
          scene.camera.target.setValues(0, 0, 0);
        },
        interactive: false,
      ),
    );
  }
}