import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class CubeGameScreen extends StatefulWidget {
  const CubeGameScreen({super.key});

  @override
  State<CubeGameScreen> createState() => _CubeGameScreenState();
}

class _CubeGameScreenState extends State<CubeGameScreen> {
  Object? machine;
  late Scene scene;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Cube(
        onSceneCreated: (Scene createdScene) {
          scene = createdScene;

          machine = Object(
            fileName: 'assets/models/machine_converted.obj',
          );

          if (machine != null) {
            machine!.lighting = true;
            scene.world.add(machine!);
          }

          // Very bright light from multiple directions
          scene.light.position.setValues(0, 20, 20);
          
          // Camera position
          scene.camera.zoom = 12;
          scene.camera.position.setValues(0, 12, 3);
          scene.camera.target.setValues(0, 0, 0);
        },
        interactive: false,
      ),
    );
  }
}