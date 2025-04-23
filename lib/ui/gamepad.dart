import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/ui/pallette.dart';
import 'package:red_ocelot/util/ltrb.dart';

class GamepadButton extends StatelessWidget {
  GamepadButton({
    super.key,
    required this.onPressed,
    this.onButtonRelease,
    this.child,
    this.size = 50,
    this.color = Colors.white,
    LTRB? position,
  }) : position = position ?? LTRB();

  final VoidCallback onPressed;
  final VoidCallback? onButtonRelease;
  final Widget? child;
  final double size;
  final Color color;
  final LTRB position;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.left,
          bottom: position.bottom,
          right: position.right,
          top: position.top,
          child: GestureDetector(
            onTapDown: (_) => onPressed(),
            onTapUp: (_) => onButtonRelease?.call(),
            onTapCancel: () => onButtonRelease?.call(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Center(child: child),
            ),
          ),
        ),
      ],
    );
  }
}

class JoystickThumb extends StatefulWidget {
  JoystickThumb({super.key, this.size = 20, Vector2? offset, color})
    : offset = offset ?? Vector2(0, 0),
      color = color ?? Colors.white;

  final double size;
  final Vector2 offset;
  final Color color;

  @override
  State<JoystickThumb> createState() => _JoystickThumbState();
}

// allow setting the position of the thumb to make it clear which
// direction the joystick is pointing
class _JoystickThumbState extends State<JoystickThumb> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.size / 2 + widget.offset.x,
      bottom: widget.size / 2 - widget.offset.y,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
      ),
    );
  }

  void setOffset(Vector2 offset) {
    setState(() {
      widget.offset.setFrom(offset);
    });
  }
}

/// A joystick widget that can be moved around the screen.
class Joystick extends StatelessWidget {
  Joystick({super.key, required this.onMove, this.size = 50});

  final Function(Vector2) onMove;
  final double size;
  final GlobalKey<_JoystickThumbState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final offset = details.localPosition;
        final center = Offset(size / 2, size / 2);
        final distance = offset - center;
        final angle = distance.direction;
        final magnitude = distance.distance;

        if (magnitude <= size) {
          final position = Vector2(
            magnitude * cos(angle),
            magnitude * sin(angle),
          );
          onMove(position * 1 / size);
          _key.currentState?.setOffset(position);
        } else {
          final position = Vector2(
            magnitude * cos(angle),
            magnitude * sin(angle),
          )..scaleTo(size);
          onMove(position * 1 / size);
          _key.currentState?.setOffset(position);
        }
      },
      onPanCancel:
          () => {
            onMove(Vector2(0, 0)),
            _key.currentState?.setOffset(Vector2(0, 0)),
          },
      onPanEnd:
          (_) => {
            onMove(Vector2(0, 0)),
            _key.currentState?.setOffset(Vector2(0, 0)),
          },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColorSecondary.withAlpha(128),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            JoystickThumb(
              key: _key,
              size: size / 2,
              color: secondaryColor.withAlpha(128),
            ),
          ],
        ),
      ),
    );
  }
}

/// A one-button, one-joystick gamepad widget.
class Gamepad extends StatelessWidget {
  Gamepad({
    super.key,
    required void Function(Vector2) this.onMove,
    required void Function() this.onButtonRelease,
    required void Function() this.onButtonPress,
    this.joystickSize = 50,
    this.buttonSize = 50,
    LTRB? joystickPosition,
    LTRB? buttonPosition,
  }) : joystickPosition = joystickPosition ?? LTRB(),
       buttonPosition = buttonPosition ?? LTRB();

  final double joystickSize;
  final double buttonSize;
  late final LTRB joystickPosition;
  late final LTRB buttonPosition;
  final Function(Vector2) onMove;
  final Function() onButtonRelease;
  final Function() onButtonPress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: joystickPosition.left,
          bottom: joystickPosition.bottom,
          right: joystickPosition.right,
          top: joystickPosition.top,
          child: Joystick(onMove: onMove, size: joystickSize),
        ),
        Positioned(
          right: buttonPosition.right,
          bottom: buttonPosition.bottom,
          left: buttonPosition.left,
          top: buttonPosition.top,
          child: GamepadButton(
            onPressed: onButtonPress,
            onButtonRelease: onButtonRelease,
            size: buttonSize,
            color: backgroundColorSecondary.withAlpha(128),
            child: Icon(
              Icons.flare,
              size: buttonSize / 2,
              color: secondaryColor.withAlpha(128),
            ),
          ),
        ),
      ],
    );
  }
}

class GamepadToggle extends StatefulWidget {
  GamepadToggle({
    super.key,
    required this.onPressed,
    this.size = 50,
    LTRB? position,
  }) : position = position ?? LTRB();

  final VoidCallback onPressed;
  final double size;
  late final LTRB position;

  @override
  State<GamepadToggle> createState() => _GamepadToggleState();
}

class _GamepadToggleState extends State<GamepadToggle> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GamepadButton(
      onPressed: () {
        setState(() {
          _isPressed = !_isPressed;
        });
        widget.onPressed();
      },
      position: widget.position,
      color: backgroundColorSecondary.withAlpha(128),
      size: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _isPressed
                        ? primaryColor.withAlpha(128)
                        : secondaryColor.withAlpha(128),
              ),
              child: Center(
                child: Icon(
                  Icons.gamepad,
                  color:
                      _isPressed
                          ? Colors.white.withAlpha(128)
                          : Colors.black.withAlpha(128),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
