// The base menu class, for main menu, pause menu, settings, etc.
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:red_ocelot/ui/pallette.dart';

class Menu extends StatelessWidget {
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
  Widget build(BuildContext buildContext) {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 24, color: textColor)),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedBox(height: 20), Divider(color: textColor)],
          ),
          ...items.map((item) {
            return GestureDetector(
              onTap: item.onTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: item.textSize ?? 18,
                    color: item.color ?? textColor,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MenuItem extends TextButton {
  /// The title of the menu item.
  final String title;

  /// The action to be performed when the menu item is tapped.
  final VoidCallback onTap;

  /// The color of the menu item.
  final Color? color;

  /// The font size of the menu item.
  final double? textSize;

  MenuItem({
    super.key,
    required this.title,
    required this.onTap,
    this.color,
    this.textSize,
  }) : super(
         onPressed: onTap,
         child: Text(
           title,
           style: TextStyle(
             fontSize: textSize ?? 18,
             color: color ?? textColor,
           ),
         ),
       );
}
