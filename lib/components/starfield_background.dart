// Updated StarfieldBackground component with limited resolution rendering

import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:red_ocelot/red_ocelot_game.dart';

class StarfieldBackground extends Component
    with HasGameReference<RedOcelotGame> {
  final FragmentShader shader;
  final Vector2 cumulativeOffset = Vector2.zero();
  double time = 0.0;
  late Vector2 screenSize;

  // Cache for the rendered shader
  Image? _cachedImage;
  double _lastTime = 0.0;
  Vector2 _lastOffset = Vector2.zero();
  Vector2 _lastScreenSize = Vector2.zero();

  // Maximum resolution for shader rendering
  static const double MAX_SHADER_DIMENSION = 512.0;

  StarfieldBackground(this.shader)
    : super(priority: -100); // Very low priority to render first

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    screenSize = size;
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    // Calculate movement for parallax effect
    final Vector2 velocityThisFrame = game.sundiver.body.linearVelocity.scaled(
      dt,
    );
    cumulativeOffset.add(velocityThisFrame.scaled(0.01));
  }

  // Calculate the limited size for shader, keeping it square
  // so it is either MAX_SHADER_DIMENSION x MAX_SHADER_DIMENSION
  // or longest side x longest side (if longest side is less than MAX_SHADER_DIMENSION)
  Size _calculateShaderSize(Size screenSize) {
    if (screenSize.width > screenSize.height) {
      return Size(
        min(screenSize.width, MAX_SHADER_DIMENSION),
        min(screenSize.width, MAX_SHADER_DIMENSION),
      );
    } else {
      return Size(
        min(screenSize.height, MAX_SHADER_DIMENSION),
        min(screenSize.height, MAX_SHADER_DIMENSION),
      );
    }
  }

  // Check if we need to regenerate the shader image
  bool _needsRegeneration() {
    // Regenerate if:
    // - No cached image exists
    // - Screen size changed
    // - Significant time change
    // - Significant offset change
    return _cachedImage == null ||
        (_lastScreenSize - screenSize).length > 0.1 ||
        ((time - _lastTime).abs() > 1 / 60 &&
            (_lastOffset - cumulativeOffset).length > 0.0);
  }

  // Generate the shader image at a limited resolution
  Image _generateShaderImage() {
    final Size shaderSize = _calculateShaderSize(screenSize.toSize());

    // Set shader uniforms
    shader.setFloatUniforms((value) {
      value
        ..setVector(shaderSize.toVector2())
        ..setFloat(cumulativeOffset.x)
        ..setFloat(cumulativeOffset.y)
        ..setFloat(time);
    });

    // Create a recorder and render the shader
    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, shaderSize.width, shaderSize.height),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, shaderSize.width, shaderSize.height),
      Paint()..shader = shader,
    );

    final picture = recorder.endRecording();
    final image = picture.toImageSync(
      shaderSize.width.ceil(),
      shaderSize.height.ceil(),
    );

    // Update cache tracking values
    _lastTime = time;
    _lastOffset = cumulativeOffset.clone();
    _lastScreenSize = screenSize.clone();

    return image;
  }

  @override
  void render(Canvas canvas) {
    // Check if we need to regenerate the shader image
    if (_needsRegeneration()) {
      _cachedImage?.dispose();
      _cachedImage = _generateShaderImage();
    }

    // Draw the cached image scaled to fill the entire screen
    if (_cachedImage != null) {
      canvas.drawImageRect(
        _cachedImage!,
        Rect.fromLTWH(
          0,
          0,
          _cachedImage!.width.toDouble(),
          _cachedImage!.height.toDouble(),
        ),
        Rect.fromCenter(
          center: Offset(screenSize.x / 2, screenSize.y / 2),
          width: max(screenSize.x, screenSize.y),
          height: max(screenSize.x, screenSize.y),
        ),
        Paint()
          ..filterQuality = FilterQuality.medium
          ..isAntiAlias = false,
      );
    }
  }

  @override
  void onRemove() {
    _cachedImage?.dispose();
    super.onRemove();
  }
}
