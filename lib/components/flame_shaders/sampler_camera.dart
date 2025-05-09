//from: renancaraujo
// https://github.com/renancaraujo/turi/blob/main/lib/game/flame_shaders/components.dart

import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:red_ocelot/components/flame_shaders/layer.dart';
import 'package:red_ocelot/components/flame_shaders/sampler_canvas.dart';

class SamplerCamera<OwnerType extends SamplerOwner> extends CameraComponent {
  SamplerCamera({
    required this.samplerOwner,
    required this.pixelRatio,
    super.world,
    super.viewport,
    super.viewfinder,
    super.backdrop,
    super.hudComponents,
  }) {
    layer = FragmentShaderLayer(
      shader: samplerOwner.shader,
      preRender: _preRender,
      canvasCreator: _createCanvas,
      passes: samplerOwner.passes,
      sampler: samplerOwner.sampler,
      pixelRatio: pixelRatio,
    );

    samplerOwner.attachCamera(this);
  }

  factory SamplerCamera.withFixedResolution({
    required double width,
    required double height,
    required OwnerType samplerOwner,
    required double pixelRatio,
    Viewfinder? viewfinder,
    World? world,
    Component? backdrop,
    List<Component>? hudComponents,
  }) {
    return SamplerCamera(
      samplerOwner: samplerOwner,
      pixelRatio: pixelRatio,
      world: world,
      viewport: FixedResolutionViewport(resolution: Vector2(width, height))
        ..addAll(hudComponents ?? []),
      viewfinder: viewfinder ?? Viewfinder(),
      backdrop: backdrop,
    );
  }

  final OwnerType samplerOwner;

  late final FragmentShaderLayer layer;

  final double pixelRatio;

  Canvas _createCanvas(PictureRecorder recorder, int pass) {
    return SamplerCanvas(
      owner: samplerOwner,
      actualCanvas: Canvas(recorder),
      pass: pass,
    );
  }

  void _preRender(Canvas canvas) {
    super.renderTree(canvas);
  }

  @override
  void renderTree(Canvas canvas) {
    final offset = viewport.position;

    canvas
      ..save()
      ..translate(
        offset.x - viewport.anchor.x * viewport.size.x,
        offset.y - viewport.anchor.y * viewport.size.y,
      );
    layer.render(canvas, viewport.size.toSize());
    //super.renderTree(canvas);
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    samplerOwner.update(dt);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    samplerOwner.onGameResize(size);
  }
}
