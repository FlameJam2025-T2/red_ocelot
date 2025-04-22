import 'dart:math';

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'package:red_ocelot/config/world_parameters.dart';
import 'package:red_ocelot/components/cluster.dart';
import 'package:red_ocelot/red_ocelet_game.dart';

class RedOceletWorld extends Forge2DWorld with HasGameReference<RedOceletGame> {
  RedOceletWorld() : super(gravity: Vector2.zero());
  final paint = Paint()..color = Colors.deepPurple;
  late Cluster cluster;

  @override
  FutureOr<void> onLoad() {
    final viewSize = game.camera.viewport;
    print("View size: $viewSize");
    cluster = Cluster(count: 20, radius: 250)..position = Vector2(500, 300);
    add(cluster);

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, game.size.x, game.size.y), paint);
  }
}

class RedOcelotMap extends Component {
  static const double size = mapSize;
  static const Rect _bounds = Rect.fromLTRB(-size, -size, size, size);
  static final Rectangle bounds = Rectangle.fromLTRB(-size, -size, size, size);

  static final Paint _paintBorder =
      Paint()
        ..color = Colors.white12
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke;
  static final Paint _paintBg = Paint()..color = const Color(0xFF333333);

  late final Random _rng;
  final int? seed;
  late final List<Paint> _paintPool;
  late final List<Rect> _rectPool;

  RedOcelotMap({this.seed}) : super(priority: 0) {
    _rng = seed != null ? Random(seed) : Random();
    _paintPool = List<Paint>.generate(
      (size / 50).ceil(),
      (_) =>
          PaintExtension.random(rng: _rng)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
      growable: false,
    );
    _rectPool = List<Rect>.generate(
      (size / 50).ceil(),
      (i) => Rect.fromCircle(center: Offset.zero, radius: size - i * 50),
      growable: false,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_bounds, _paintBg);
    canvas.drawRect(_bounds, _paintBorder);
    for (var i = 0; i < (size / 50).ceil(); i++) {
      canvas.drawCircle(Offset.zero, size - i * 50, _paintPool[i]);
      canvas.drawRect(_rectPool[i], _paintBorder);
    }
  }

  static Vector2 generateCoordinates() {
    return Vector2.random()
      ..scale(2 * size)
      ..sub(Vector2.all(size));
  }
}
