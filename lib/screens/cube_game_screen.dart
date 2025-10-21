import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'dart:math' as math;
import '../models/level_settings.dart';

class CubeGameScreen extends StatefulWidget {
  const CubeGameScreen({super.key});

  @override
  State<CubeGameScreen> createState() => _CubeGameScreenState();
}

class _CubeGameScreenState extends State<CubeGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _leverRotation;
  Object? _leverPivot;
  Object? _lever;
  Scene? _scene;
  bool _isPulled = false;

  double _currentRotationX = 0.0;
  double _currentPositionX = 0.0;
  bool _isDragging = false;
  Offset? _dragStartPos;
  double _dragStartRotationX = 0.0;
  double _dragStartPositionX = 0.0;

  final LevelSettings _levelSettings = LevelSettings.level1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _leverRotation = Tween<double>(begin: 0.0, end: math.pi / 2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _leverRotation.addListener(() {
      if (_leverPivot != null && !_isDragging) {
        _updateLeverTransform(_leverRotation.value, _currentPositionX);
      }
    });
  }

  void _updateLeverTransform(double angleX, double positionX) {
    if (_leverPivot == null || _scene == null) return;

    _currentRotationX = angleX;
    _currentPositionX = positionX;

    print('ROTATION X: $angleX radians (${angleX * 180 / math.pi} degrees), POSITION X: $positionX');

    // Rotate around X axis for up/down motion
    _leverPivot!.rotation.setValues(angleX, 0, 0);

    // Get current position and only update X, preserve Y and Z
    final currentPos = _leverPivot!.position;
    _leverPivot!.position.setValues(positionX, currentPos.y, currentPos.z);

    _leverPivot!.updateTransform();
    _scene!.update();
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStartPos = details.localPosition;
      _dragStartRotationX = _currentRotationX;
      _dragStartPositionX = _currentPositionX;
      print('DRAG START - Current rotation X: $_currentRotationX, Position X: $_currentPositionX');
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_dragStartPos == null) return;

    setState(() {
      final deltaY = details.localPosition.dy - _dragStartPos!.dy;
      final deltaX = details.localPosition.dx - _dragStartPos!.dx;

      // Sensitivity for rotation (Y drag controls X rotation)
      final rotationSensitivity = 0.05;
      final newRotationX = (_dragStartRotationX + (deltaY * rotationSensitivity))
          .clamp(_levelSettings.minRotation, _levelSettings.maxRotation);

      // Reduced sensitivity for sliding (X drag controls X position)
      final slideSensitivity = 0.003;
      final newPositionX = (_dragStartPositionX + (deltaX * slideSensitivity))
          .clamp(_levelSettings.minX, _levelSettings.maxX);

      print('DRAG UPDATE - deltaX: $deltaX, deltaY: $deltaY, newRotX: $newRotationX, newPosX: $newPositionX');

      _updateLeverTransform(newRotationX, newPositionX);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragStartPos = null;

      print('DRAG END - Final rotation X: $_currentRotationX, Position X: $_currentPositionX');

      final midPoint = math.pi / 2;
      if (_currentRotationX < midPoint) {
        _animationController.animateTo(0.0);
        _isPulled = false;
      } else {
        _animationController.animateTo(1.0);
        _isPulled = true;
      }
    });
  }

  void _toggleLever() {
    setState(() {
      _isPulled = !_isPulled;
      if (_isPulled) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTapDown: (details) {
          if (!_isDragging) {
            _toggleLever();
          }
        },
        onPanStart: _onDragStart,
        onPanUpdate: _onDragUpdate,
        onPanEnd: _onDragEnd,
        child: Cube(
          onSceneCreated: (Scene scene) {
            _scene = scene;
            
            final machine = Object(
              fileName: 'assets/models/machine_converted.obj',
            );
            machine.lighting = true;
            scene.world.add(machine);

            final dial = Object(
              fileName: 'assets/models/floor_dial_converted.obj',
            );
            dial.lighting = false;
            dial.position.setValues(0, 3.1, 0.52);
            dial.rotation.setValues(-math.pi / 2, 0, 0);
            dial.scale.setValues(0.35, 0.35, 0.35);
            dial.updateTransform();
            scene.world.add(dial);

            _lever = Object(
              fileName: 'assets/models/simple_lever_transformed.obj',
            );
            _lever!.lighting = true;
            // POSITIVE Y moves it down/back into the machine
            _lever!.position.setValues(0, -1, -0.25);
            _lever!.scale.setValues(1.875, 1.875, 1.875);
            _lever!.updateTransform();
            scene.world.add(_lever!);

            _leverPivot = _lever;

            scene.light.position.setValues(0, 50, 50);
            
            scene.camera.zoom = 12;
            scene.camera.position.setValues(0, 12, 3);
            scene.camera.target.setValues(0, 0, 0);
          },
          interactive: false,
        ),
      ),
    );
  }
}