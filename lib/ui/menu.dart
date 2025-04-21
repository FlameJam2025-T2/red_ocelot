// The base menu class, for main menu, pause menu, settings, etc.
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/ui/pallette.dart';
import 'package:flutter/services.dart';

class MenuItem {
  final String title;
  final VoidCallback onPressed;

  final Widget child;

  MenuItem({required this.title, required this.onPressed, Widget? child})
    : child = child ?? Text(title);
}

class Menu extends StatefulWidget {
  /// The title of the menu.
  final String title;

  /// The list of menu items.
  final List<MenuItem> items;

  /// The background color of the menu.
  final Color backgroundColor;

  final FlameGame game;

  const Menu({
    super.key,
    required this.game,
    required this.title,
    required this.items,
    this.backgroundColor = backgroundColorSecondary,
  });

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  static const ButtonStyle style = ButtonStyle(
    fixedSize: WidgetStatePropertyAll<Size?>(Size(200, 50)),
    shape: WidgetStateProperty<OutlinedBorder?>.fromMap(
      <WidgetStatesConstraint, OutlinedBorder?>{
        WidgetState.selected: RoundedRectangleBorder(),
        WidgetState.any: RoundedRectangleBorder(),
      },
    ),
    side: WidgetStateProperty<BorderSide?>.fromMap(
      <WidgetStatesConstraint, BorderSide?>{
        WidgetState.selected: BorderSide(color: textColorHighlight, width: 2),
        WidgetState.any: BorderSide(color: textColor, width: 2),
      },
    ),
    foregroundColor: WidgetStateProperty<Color?>.fromMap(
      <WidgetStatesConstraint, Color?>{
        WidgetState.selected: textColorHighlight,
        WidgetState.any: textColor,
      },
    ),
    textStyle: WidgetStateProperty<TextStyle?>.fromMap(<
      WidgetStatesConstraint,
      TextStyle?
    >{
      WidgetState.selected: TextStyle(color: textColorHighlight, fontSize: 20),

      WidgetState.any: TextStyle(color: textColor, fontSize: 20),
    }),
  );

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 32,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Divider(color: textColor, thickness: 2),
            ],
          ),
          const SizedBox(height: 20),

          ...widget.items.map((item) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MenuItem(
                  selected: false,
                  onPressed: item.onPressed,
                  style: style,
                  child: item.child,
                ),
                const SizedBox(height: 10),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final bool selected;

  /// The callback function when the menu item is pressed.
  final VoidCallback onPressed;

  final ButtonStyle? style;

  final Widget child;

  const _MenuItem({
    required this.selected,
    this.style,
    required this.onPressed,
    required this.child,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  late final WidgetStatesController statesController;

  @override
  void initState() {
    super.initState();
    statesController = WidgetStatesController(<WidgetState>{
      if (widget.selected) WidgetState.selected,
    });
  }

  @override
  void didUpdateWidget(_MenuItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      statesController.update(WidgetState.selected, widget.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      statesController: statesController,
      onHover: (bool isHovered) {
        setState(() {
          statesController.update(WidgetState.selected, isHovered);
        });
      },
      style: widget.style,
      child: widget.child,
    );
  }
}
