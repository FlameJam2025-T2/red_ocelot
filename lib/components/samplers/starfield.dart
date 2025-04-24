import 'dart:typed_data';
import 'dart:ui';

import 'package:red_ocelot/components/flame_shaders/sampler_canvas.dart';
import 'package:red_ocelot/components/flame_shaders/layer.dart';
import 'package:red_ocelot/components/flame_shaders/sampler_camera.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/red_ocelot_world.dart';
import 'package:flame/extensions.dart';
// import 'package:flutter_shaders/flutter_shaders.dart';

// class StarfieldSamplerOwner extends SamplerOwner {
//   StarfieldSamplerOwner(super.shader, this.world);

//   final RedocelotWorld world;

//   @override
//   int get passes => 0;

//   @override
//   void sampler(List<Image> images, Size size, Canvas canvas) {
//     final origin = cameraComponent!.visibleWorldRect.topLeft.toVector2();

//     final theBall = world.theBall;

//     final ballpos = theBall.absolutePosition;

//     final uvBall = (ballpos - origin)..divide(kCameraSize.asVector2);

//     final velocity = theBall.velocity.clone() / 1600;

//     shader.setFloatUniforms((value) {
//       value
//         ..setSize(size)
//         ..setVector64(uvBall)
//         ..setVector64(-velocity)
//         ..setFloat(theBall.gama)
//         ..setFloat(theBall.radius);
//     });

//     canvas
//       ..save()
//       ..drawRect(
//         Offset.zero & size,
//         Paint()
//           ..shader = shader
//           ..blendMode = BlendMode.lighten,
//       )
//       ..restore();
//   }
// }

// extension on UniformsSetter {
//   void setVector64(Vector vector) {
//     final storage = Float32List.fromList(vector.storage);

//     setFloats(storage);
//   }
// }
