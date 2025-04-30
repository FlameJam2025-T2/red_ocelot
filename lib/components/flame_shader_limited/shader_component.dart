import 'dart:math';
import 'dart:ui';
import 'package:flame/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

abstract class ShaderComponent<T extends FlameGame> extends PositionComponent
    with HasGameReference<T> {
  final FragmentShader shader;
  double time = 0.0;
  double minUpdateInterval = 1 / 60; // 60 FPS
  double zoom = 1.0;
  final Vector2 shaderDestSize = Vector2.zero();
  final Vector2 screenSize = Vector2.zero();
  final BlendMode blendMode;
  Offset destOffsetFromCenter;

  // Cache for the rendered shader
  Image? _cachedImage;
  double _lastTime = 0.0;
  final Vector2 _lastDestSize = Vector2.zero();

  // Maximum resolution for shader rendering
  final double maxShaderDimension;
  final double shaderAspectRatio;

  ShaderComponent(
    this.shader, {
    required Vector2 destSize,
    this.maxShaderDimension = 512.0,
    this.shaderAspectRatio = 1.0,
    this.blendMode = BlendMode.srcOver,
    this.destOffsetFromCenter = Offset.zero,
  }) : super(priority: -100) {
    // Set the initial shader destination size
    shaderDestSize.setFrom(destSize);
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
    // shader.setFloatUniforms((value) {
    //   value
    //     ..setVector(shaderSize.toVector2())
    //     ..setFloat(cumulativeOffset.x)
    //     ..setFloat(cumulativeOffset.y)
    //     ..setFloat(time);
    // });

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
          center: destOffset,
          width: shaderDestSize.x,
          height: shaderDestSize.y,
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
