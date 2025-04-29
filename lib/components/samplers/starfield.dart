import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:red_ocelot/components/flame_shaders/sampler_canvas.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:flame/extensions.dart';
//import 'package:vector_math/vector_math_64.dart' as v64;

class StarfieldSamplerOwner extends SamplerOwner {
  StarfieldSamplerOwner(super.shader, this.game) : super();

  final RedOcelotGame game;
  late final Vector2 viewportSize = Vector2.zero();
  final Vector2 cumulativeOffset = Vector2.zero();
  double time = 0.0;
  double scaleFactor = 1;
  Image? _cachedImage;
  final Map<String, dynamic> _cacheProps = {
    'position': Vector2.zero(),
    'size': Size.zero,
    'viewportSize': Vector2.zero(),
    'scaleFactor': 0.0,
    'cumulativeOffset': Vector2.zero(),
  };

  @override
  int get passes => 0;

  @override
  void attachCamera(CameraComponent cameraComponent) {
    super.attachCamera(cameraComponent);
    viewportSize.setFrom(
      RedOcelotGame.limitedShaderSize(cameraComponent.viewport.size),
    );
  }

  Image _cacheOrGenerate(Size size) {
    if (_cachedImage != null &&
        _cacheProps['position'] == game.sundiver.position &&
        _cacheProps['size'] == size &&
        _cacheProps['viewportSize'] == viewportSize &&
        _cacheProps['scaleFactor'] == scaleFactor &&
        _cacheProps['cumulativeOffset'] == cumulativeOffset) {
      return _cachedImage!;
    }

    shader.setFloatUniforms((value) {
      value
        ..setVector(size.toVector2() * (1 / scaleFactor))
        ..setFloat(cumulativeOffset.x)
        ..setFloat(cumulativeOffset.y)
        ..setFloat(time);
    });
    final Paint shaderPaint =
        Paint()
          ..shader = shader
          ..blendMode = BlendMode.srcOver;

    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
    );
    canvas.drawRect(
      Rect.fromLTWH(
        game.sundiver.position.x * (1 / scaleFactor),
        game.sundiver.position.y * (1 / scaleFactor),
        viewportSize.x,
        viewportSize.y,
      ),
      shaderPaint,
    );
    final picture = recorder.endRecording();
    _cachedImage = picture.toImageSync(
      (size.width).ceil(),
      (size.height).ceil(),
    );
    _cacheProps['position'] = game.sundiver.position;
    _cacheProps['size'] = size;
    _cacheProps['viewportSize'] = viewportSize;
    _cacheProps['scaleFactor'] = scaleFactor;
    _cacheProps['cumulativeOffset'] = cumulativeOffset;
    return _cachedImage!;
  }

  @override
  void sampler(List<Image> images, Size size, Canvas canvas) {
    if (kDebugMode) {
      print('StarfieldSamplerOwner.sampler');
      print(viewportSize);
      print(size);
      print(scaleFactor);
      print(cameraComponent?.viewport.size);
      print(cameraComponent?.viewport.position);
      print(cameraComponent?.viewfinder.position);
    }

    final img = _cacheOrGenerate(size);

    canvas.save();
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, size.width, size.height),
      Rect.fromCenter(
        center: Offset(
          game.sundiver.position.x * scaleFactor,
          game.sundiver.position.y * scaleFactor,
        ),
        width: size.width * scaleFactor / 2,
        height: size.height * scaleFactor / 2,
      ),
      Paint()
        ..color = Colors.white
        ..blendMode = BlendMode.srcOver,
    );
    canvas.restore();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    cameraComponent?.viewport.size = size;
    viewportSize.setFrom(RedOcelotGame.limitedShaderSize(size));
    if (kDebugMode) {
      print('StarfieldSamplerOwner.onGameResize');
      print(cameraComponent?.viewport.size);
    }
    scaleFactor = size.length / viewportSize.length;
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    // Calculate how much the position changed this frame
    Vector2 velocityThisFrame = game.sundiver.body.linearVelocity.scaled(dt);

    // Add to our cumulative offset
    cumulativeOffset.add(velocityThisFrame.scaled(0.0001));
  }
}
