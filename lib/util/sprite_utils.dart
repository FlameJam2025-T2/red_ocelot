import 'package:flame/components.dart';
import 'package:flame/flame.dart';

enum SpriteName { monsterA, monsterB, monsterC, monsterD, monsterE, ufo }

class SpriteInfo {
  final String fileName;
  final int frames;
  final int framesPerRow;
  final Vector2 frameSize;
  final double stepTime;

  SpriteInfo({
    required this.fileName,
    required this.frames,
    required this.framesPerRow,
    required this.frameSize,
    required this.stepTime,
  });
}

extension SpriteTypeExtension on SpriteName {
  SpriteInfo get fileInfo {
    switch (this) {
      case SpriteName.monsterA:
        return SpriteInfo(
          fileName: "SpaceMonsters/SpaceMonsterA.png",
          frames: 2,
          framesPerRow: 2,
          frameSize: Vector2(57, 57),
          stepTime: 0.05,
        );
      case SpriteName.monsterB:
        return SpriteInfo(
          fileName: "SpaceMonsters/SpaceMonsterB.png",
          frames: 2,
          framesPerRow: 2,
          frameSize: Vector2(57, 57),
          stepTime: 0.07,
        );
      case SpriteName.monsterC:
        return SpriteInfo(
          fileName: "SpaceMonsters/SpaceMonsterC.png",
          frames: 2,
          framesPerRow: 2,
          frameSize: Vector2(57, 57),
          stepTime: 0.07,
        );
      case SpriteName.monsterD:
        return SpriteInfo(
          fileName: "SpaceMonsters/SpaceMonsterD.png",
          frames: 2,
          framesPerRow: 2,
          frameSize: Vector2(57, 57),
          stepTime: 0.07,
        );
      case SpriteName.monsterE:
        return SpriteInfo(
          fileName: "SpaceMonsters/SpaceMonsterE.png",
          frames: 2,
          framesPerRow: 2,
          frameSize: Vector2(57, 57),
          stepTime: 0.07,
        );
      case SpriteName.ufo:
        return SpriteInfo(
          fileName: "UFO/UFO.png",
          frames: 3,
          framesPerRow: 3,
          frameSize: Vector2(113, 86),
          stepTime: 0.2,
        );
    }
  }
}

class AnimatedSprite extends SpriteAnimationComponent {
  final SpriteName spriteName;

  AnimatedSprite({required this.spriteName}) : super(size: Vector2(100, 100));

  @override
  Future<void> onLoad() async {
    final spriteSheet = await Flame.images.load(spriteName.fileInfo.fileName);

    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: spriteName.fileInfo.frames, // Dynamic frame count
        amountPerRow:
            spriteName.fileInfo.framesPerRow >= spriteName.fileInfo.frames
                ? null
                : spriteName.fileInfo.framesPerRow,
        textureSize: spriteName.fileInfo.frameSize, // Dynamic frame size
        stepTime: spriteName.fileInfo.stepTime, // Speed of animation
      ),
    );
  }
}
