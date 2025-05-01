import 'dart:math';
import 'dart:ui';
import 'package:flame/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

enum ScaleMode {
  /// Scale the shader to fit the screen, maintaining the aspect ratio.
  fit,

  /// Scale the shader to fill the screen, maintaining the aspect ratio.
  /// this is the default.
  cover,

  /// Scale the shader to fill the screen, ignoring the aspect ratio.
  stretch,

  /// do not scale
  none,
}

abstract class ShaderComponent<T extends FlameGame> extends PositionComponent
    with HasGameReference<T> {
  final FragmentShader shader;
  double time = 0.0;
  double minUpdateInterval = 1 / 60; // 60 FPS
  double zoom = 1.0;
  final Vector2 shaderDestSize = Vector2.zero();
  late final double shaderAspectRatio;
  final Vector2 screenSize = Vector2.zero();
  final BlendMode blendMode;
  Offset destOffsetFromCenter;
  final ScaleMode scaleMode;
  bool enabled = true;

  // Cache for the rendered shader
  Image? _cachedImage;
  double _lastTime = 0.0;
  final Vector2 _lastDestSize = Vector2.zero();
  final Vector2 _lastScaledDestSize = Vector2.zero();

  // Maximum resolution for shader rendering
  final double maxShaderDimension;

  ShaderComponent(
    this.shader, {
    required Vector2 destSize,
    this.maxShaderDimension = 512.0,
    this.blendMode = BlendMode.srcOver,
    this.destOffsetFromCenter = Offset.zero,
    this.scaleMode = ScaleMode.cover,
  }) : super(priority: -100) {
    // Set the initial shader destination size
    shaderDestSize.setFrom(destSize);
    // Calculate the shader aspect ratio
    shaderAspectRatio = shaderDestSize.x / shaderDestSize.y;
  }

  /// Update the shader destination size and / or other offsets if the
  /// game is resized.
  @override
  @mustCallSuper
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    screenSize.setFrom(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
  }

  // Calculate the limited size for shader, based on the shader aspect ratio
  // and the maximum shader dimension. If the screen size is less than the
  // maximum shader dimension, it will use the screen size (maintaining the
  // shader aspect ratio).
  @protected
  Vector2 calculateShaderSize(Vector2 destSize) {
    double width = min(destSize.x, maxShaderDimension);
    double height = width / shaderAspectRatio;

    if (height > maxShaderDimension) {
      height = min(destSize.y, maxShaderDimension);
      width = height * shaderAspectRatio;
    }

    return Vector2(width, height);
  }

  @protected
  Vector2 calculateRenderSize(Vector2 shaderSize, Vector2 destSize) {
    // Calculate the render size based on the scale mode
    switch (scaleMode) {
      case ScaleMode.none:
        return shaderSize;
      case ScaleMode.stretch:
        return destSize;
      case ScaleMode.cover:
        // make sure the shader is at least as big as the destSize (it's ok if
        // one dimension is larger)
        // but we maintain the aspect ratio of the shader

        // if the shader is larger than the destSize, we need to scale it down
        // to fit
        if (destSize.x > destSize.y) {
          return Vector2(destSize.x, destSize.x / shaderAspectRatio);
        } else {
          return Vector2(destSize.y * shaderAspectRatio, destSize.y);
        }

      case ScaleMode.fit:
        // make sure the shader completely fits in the destSize
        // (it's ok if one dimension is smaller)
        // but we maintain the aspect ratio of the shader
        if (shaderSize.x > shaderSize.y) {
          return Vector2(destSize.x, destSize.x / shaderAspectRatio);
        } else {
          return Vector2(destSize.y * shaderAspectRatio, destSize.y);
        }
    }
  }

  // Check if we need to regenerate the shader image
  @protected
  bool needsRegeneration() {
    return true;
  }

  @protected
  Offset get destOffset {
    return Offset(
      screenSize.x - shaderDestSize.x / 2 + destOffsetFromCenter.dx,
      screenSize.y - shaderDestSize.y / 2 + destOffsetFromCenter.dy,
    );
  }

  bool _needsRegeneration() {
    // Regenerate if:
    // - No cached image exists
    // - Screen size changed
    // - Significant time change
    // - Significant offset change
    return _cachedImage == null ||
        (_lastDestSize - shaderDestSize).length > 0.1 ||
        (needsRegeneration() && (time - _lastTime).abs() > minUpdateInterval);
  }

  @protected
  void setShaderUniforms(Vector2 renderSize) {}

  // Generate the shader image at a limited resolution
  Image _generateShaderImage() {
    final Vector2 shaderSize = calculateShaderSize(shaderDestSize * zoom);

    // Set shader uniforms
    setShaderUniforms(shaderSize);

    // Create a recorder and render the shader
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, shaderSize.x, shaderSize.y),
      Paint()
        ..shader = shader
        ..blendMode = blendMode,
    );

    final picture = recorder.endRecording();
    final image = picture.toImageSync(shaderSize.x.ceil(), shaderSize.y.ceil());

    // Update cache tracking values
    _lastTime = time;
    _lastDestSize.setFrom(shaderDestSize);
    _lastScaledDestSize.setFrom(
      calculateRenderSize(shaderSize, shaderDestSize),
    );

    return image;
  }

  @override
  void render(Canvas canvas) {
    if (!enabled) {
      return;
    }
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
          center: destOffset,
          width: _lastScaledDestSize.x,
          height: _lastScaledDestSize.y,
        ),
        Paint()
          ..filterQuality = FilterQuality.medium
          ..isAntiAlias = true,
      );
    }
  }

  @override
  void onRemove() {
    _cachedImage?.dispose();
    super.onRemove();
  }
}
