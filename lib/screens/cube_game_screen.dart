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
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _leverRotation;
  late AnimationController _resetAnimationController;
  late Animation<double> _resetRotationAnimation;
  late Animation<double> _resetPositionAnimation;
  Object? _leverPivot;
  Object? _lever;
  Object? _greenBulb;
  Scene? _scene;
  bool _isPulled = false;

  double _currentRotationX = 0.0;
  double _currentPositionX = 0.0;
  bool _isDragging = false;
  Offset? _dragStartPos;
  double _dragStartRotationX = 0.0;
  double _dragStartPositionX = 0.0;

  int _currentLevelIndex = 0;
  LevelSettings get _levelSettings => LevelSettings.levels[_currentLevelIndex];

  // Wiggle detection
  double _lastPositionX = 0.0;
  int _directionChanges = 0;
  int _lastDirectionSign = 0;
  DateTime _lastDirectionChangeTime = DateTime.now();
  DateTime _lastWiggleTime = DateTime.now().subtract(const Duration(seconds: 3)); // Allow immediate first wiggle

  // Rotation event detection
  bool _hasReachedMaxRotation = false;

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

    // Reset animation controller for level transitions
    _resetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _resetRotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _resetAnimationController, curve: Curves.easeInOutCubic),
    );
    _resetPositionAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _resetAnimationController, curve: Curves.easeInOutCubic),
    );
    _resetAnimationController.addListener(() {
      if (_leverPivot != null) {
        _updateLeverTransform(_resetRotationAnimation.value, _resetPositionAnimation.value);
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

  void _changeBulbColor(double red, double green, double blue) {
    if (_greenBulb == null || _scene == null) return;

    // Change the diffuse color of the bulb's material
    _greenBulb!.mesh.material.diffuse.setValues(red, green, blue);
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

    // Lock dragging if we're on the last level with no event
    if (_currentLevelIndex >= LevelSettings.levels.length - 1 && _levelSettings.event == 'none') {
      return;
    }

    setState(() {
      final deltaY = details.localPosition.dy - _dragStartPos!.dy;
      final deltaX = details.localPosition.dx - _dragStartPos!.dx;

      // Sensitivity for rotation (Y drag controls X rotation)
      final rotationSensitivity = 0.1;
      final newRotationX = (_dragStartRotationX + (deltaY * rotationSensitivity))
          .clamp(_levelSettings.minRotation, _levelSettings.maxRotation);

      // Reduced sensitivity for sliding (X drag controls X position)
      final slideSensitivity = 0.003;
      final newPositionX = (_dragStartPositionX + (deltaX * slideSensitivity))
          .clamp(_levelSettings.minX, _levelSettings.maxX);

      print('DRAG UPDATE - deltaX: $deltaX, deltaY: $deltaY, newRotX: $newRotationX, newPosX: $newPositionX');

      bool levelChanged = false;

      // Detect wiggle - fast back-and-forth in X direction
      final deltaFromLast = newPositionX - _lastPositionX;
      if (deltaFromLast.abs() > 0.001) { // Only track significant movements
        final currentDirectionSign = deltaFromLast > 0 ? 1 : -1;

        if (_lastDirectionSign != 0 && currentDirectionSign != _lastDirectionSign) {
          _directionChanges++;
          final now = DateTime.now();
          final timeSinceLastChange = now.difference(_lastDirectionChangeTime).inMilliseconds;

          // If we've changed direction 3+ times rapidly (within 500ms between changes)
          if (_directionChanges >= 3 && timeSinceLastChange < 500) {
            final now = DateTime.now();
            final timeSinceLastWiggle = now.difference(_lastWiggleTime).inMilliseconds;

            // Require at least 2 seconds between successful wiggles
            if (timeSinceLastWiggle >= 2000) {
              print('WIGGLED');
              _directionChanges = 0; // Reset after detecting wiggle
              _lastWiggleTime = now; // Update last wiggle time

              // Check if current level's event is 'wiggle' before advancing
              if (_levelSettings.event == 'wiggle' && _currentLevelIndex < LevelSettings.levels.length - 1) {
                _currentLevelIndex++;
                print('Level advanced to $_currentLevelIndex');

                // Update bulb brightness based on level settings
                _changeBulbColor(0.0, _levelSettings.brightness, 0.0);

                // Animate lever to start position for new level
                _animateToResetPosition(_levelSettings.startRotationX, _levelSettings.startPositionX);
                levelChanged = true;
              } else if (_levelSettings.event != 'wiggle') {
                print('Wiggle detected but current level event is: ${_levelSettings.event}');
              }
            } else {
              print('Wiggle detected but cooldown active (${2000 - timeSinceLastWiggle}ms remaining)');
              _directionChanges = 0; // Reset to prevent continuous triggering
            }
          }

          _lastDirectionChangeTime = now;
        }

        _lastDirectionSign = currentDirectionSign;
        _lastPositionX = newPositionX;
      }

      // Check for rotation event - detect when rotation reaches max
      if (_levelSettings.event == 'rotation' && !_hasReachedMaxRotation) {
        // Check if rotation is at or very close to max (within 0.1 radians)
        if (newRotationX >= _levelSettings.maxRotation - 0.1) {
          _hasReachedMaxRotation = true;
          print('REACHED MAX ROTATION');

          // Advance to next level
          if (_currentLevelIndex < LevelSettings.levels.length - 1) {
            _currentLevelIndex++;
            print('Level advanced to $_currentLevelIndex');

            // Update bulb brightness based on level settings
            _changeBulbColor(0.0, _levelSettings.brightness, 0.0);

            // Animate lever to start position for new level
            _animateToResetPosition(_levelSettings.startRotationX, _levelSettings.startPositionX);
            levelChanged = true;

            // Reset for next level
            _hasReachedMaxRotation = false;
          }
        }
      }

      if (!levelChanged) {
        _updateLeverTransform(newRotationX, newPositionX);
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragStartPos = null;

      // Reset wiggle detection
      _directionChanges = 0;
      _lastDirectionSign = 0;

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

  void _animateToResetPosition(double targetRotationX, double targetPositionX) {
    // Update the animation tweens with current and target values
    _resetRotationAnimation = Tween<double>(
      begin: _currentRotationX,
      end: targetRotationX,
    ).animate(
      CurvedAnimation(parent: _resetAnimationController, curve: Curves.easeInOutCubic),
    );
    _resetPositionAnimation = Tween<double>(
      begin: _currentPositionX,
      end: targetPositionX,
    ).animate(
      CurvedAnimation(parent: _resetAnimationController, curve: Curves.easeInOutCubic),
    );

    // Reset and start the animation
    _resetAnimationController.reset();
    _resetAnimationController.forward().then((_) {
      // Update final values after animation completes
      _currentRotationX = targetRotationX;
      _currentPositionX = targetPositionX;
      _dragStartRotationX = targetRotationX;
      _dragStartPositionX = targetPositionX;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resetAnimationController.dispose();
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

            _greenBulb = Object(
              fileName: 'assets/models/green_bulb._transforms_2.obj',
            );
            _greenBulb!.lighting = true;  // Enable lighting for shading
            _greenBulb!.position.setValues(0.1, 1.15, 0);
            _greenBulb!.scale.setValues(0.06, 0.06, 0.06);
            _greenBulb!.updateTransform();
            scene.world.add(_greenBulb!);

            // Set initial brightness based on level 0
            _changeBulbColor(0.0, _levelSettings.brightness, 0.0);

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