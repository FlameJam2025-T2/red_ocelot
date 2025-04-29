// import 'dart:ui';

// import 'package:flame/components.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart' show Colors;
// import 'package:red_ocelot/components/flame_shaders/sampler_canvas.dart';
// import 'package:red_ocelot/red_ocelot_game.dart';
// import 'package:flame/extensions.dart';

// class StarfieldSamplerOwner extends SamplerOwner {
//   StarfieldSamplerOwner(super.shader, this.game) : super();

//   final RedOcelotGame game;
//   final Vector2 cumulativeOffset = Vector2.zero();
//   double time = 0.0;

//   // Fixed maximum resolution for the shader
//   static const double MAX_SHADER_RESOLUTION = 256.0;

//   // Cache for the generated image
//   Image? _cachedImage;
//   // Properties to track when to regenerate the cache
//   Vector2 _lastPlayerPosition = Vector2.zero();
//   Vector2 _lastCumulativeOffset = Vector2.zero();
//   double _lastTime = 0.0;
//   Size _lastViewportSize = Size.zero;

//   @override
//   int get passes => 0;

//   @override
//   void attachCamera(CameraComponent cameraComponent) {
//     super.attachCamera(cameraComponent);
//   }

//   // Generate the shader image with a limited resolution
//   Image _generateShaderImage(Size viewportSize) {
//     // Calculate resolution with correct aspect ratio
//     final double aspectRatio = viewportSize.width / viewportSize.height;
//     final Size shaderSize =
//         aspectRatio > 1.0
//             ? Size(MAX_SHADER_RESOLUTION, MAX_SHADER_RESOLUTION / aspectRatio)
//             : Size(MAX_SHADER_RESOLUTION * aspectRatio, MAX_SHADER_RESOLUTION);

//     if (kDebugMode) {
//       print(
//         'Generating starfield shader at resolution: ${shaderSize.width.toStringAsFixed(1)}x${shaderSize.height.toStringAsFixed(1)}',
//       );
//     }

//     // Set shader uniforms
//     shader.setFloatUniforms((value) {
//       value
//         ..setVector(shaderSize.toVector2())
//         ..setFloat(cumulativeOffset.x)
//         ..setFloat(cumulativeOffset.y)
//         ..setFloat(time);
//     });

//     // Create recorder and render
//     final recorder = PictureRecorder();
//     final canvas = Canvas(
//       recorder,
//       Rect.fromLTWH(0, 0, shaderSize.width, shaderSize.height),
//     );

//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, shaderSize.width, shaderSize.height),
//       Paint()..shader = shader,
//     );

//     final picture = recorder.endRecording();
//     return picture.toImageSync(
//       shaderSize.width.ceil(),
//       shaderSize.height.ceil(),
//     );
//   }

//   // Check if we need to regenerate the shader
//   bool _needsRegeneration(Vector2 playerPosition, Size viewportSize) {
//     if (_cachedImage == null) return true;

//     // Check if significant changes have occurred
//     final playerMoved = (playerPosition - _lastPlayerPosition).length > 10.0;
//     final offsetChanged =
//         (cumulativeOffset - _lastCumulativeOffset).length > 0.005;
//     final timeChanged = (time - _lastTime).abs() > 1.0;
//     final sizeChanged =
//         viewportSize.width != _lastViewportSize.width ||
//         viewportSize.height != _lastViewportSize.height;

//     return playerMoved || offsetChanged || timeChanged || sizeChanged;
//   }

//   @override
//   void sampler(List<Image> images, Size viewportSize, Canvas canvas) {
//     final playerPosition = game.sundiver.position;

//     // Check if we need to regenerate
//     if (_needsRegeneration(playerPosition, viewportSize)) {
//       _cachedImage = _generateShaderImage(viewportSize);

//       // Update tracking properties
//       _lastPlayerPosition = playerPosition.clone();
//       _lastCumulativeOffset = cumulativeOffset.clone();
//       _lastTime = time;
//       _lastViewportSize = viewportSize;
//     }

//     // Draw the shader image to fill the entire viewport
//     canvas.save();
//     canvas.drawImageRect(
//       _cachedImage!,
//       Rect.fromLTWH(
//         0,
//         0,
//         _cachedImage!.width.toDouble(),
//         _cachedImage!.height.toDouble(),
//       ),
//       Rect.fromLTWH(0, 0, viewportSize.width, viewportSize.height),
//       Paint()
//         ..filterQuality = FilterQuality.medium
//         ..color = Colors.white
//         ..blendMode = BlendMode.srcOver,
//     );
//     canvas.restore();
//   }

//   @override
//   void onGameResize(Vector2 size) {
//     super.onGameResize(size);
//     if (kDebugMode) {
//       print('StarfieldSamplerOwner.onGameResize: $size');
//     }
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     time += dt;

//     // Calculate movement for parallax effect
//     Vector2 velocityThisFrame = game.sundiver.body.linearVelocity.scaled(dt);

//     // Scale velocity to control parallax intensity
//     // Use a small value to make the stars move slower than the ship
//     cumulativeOffset.add(velocityThisFrame.scaled(0.0001));

//     // Keep the offset values from growing too large (prevent floating point issues)
//     cumulativeOffset.x = _wrapValue(cumulativeOffset.x, -1.0, 1.0);
//     cumulativeOffset.y = _wrapValue(cumulativeOffset.y, -1.0, 1.0);
//   }

//   // Utility function to wrap values within a range
//   double _wrapValue(double value, double min, double max) {
//     final range = max - min;
//     double result = value;

//     while (result < min) {
//       result += range;
//     }
//     while (result > max) {
//       result -= range;
//     }

//     return result;
//   }
// }

// This is a complete replacement for your StarfieldSamplerOwner class
// in lib/components/samplers/starfield.dart
