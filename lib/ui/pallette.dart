/// This file contains the color pallette to ensure consistency across the game.
/// This of course is mainly for UI and menu components but can be used in the
/// game as well.
library;

import 'package:flutter/material.dart';

/// General theme colors for the game elements.
const Color primaryColor = Color.fromARGB(255, 203, 0, 182);
const Color secondaryColor = Color.fromARGB(255, 0, 182, 203);
const Color tertiaryColor = Color.fromARGB(255, 182, 203, 0);

/// Text color for the game.
const Color textColor = Color.fromARGB(255, 239, 36, 185);
const Color textColorHighlight = Color.fromARGB(255, 0, 170, 0);

/// Background colors for the game.
const Color backgroundColor = Color.fromARGB(255, 44, 44, 44);
const Color backgroundColorSecondary = Color.fromARGB(255, 50, 0, 64);

/// Shadow color for the game.
const Color shadowColor = Color.fromARGB(30, 0, 0, 0);

/// For material design, if we use it. This is just a placeholder for now.
const ColorScheme colorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: backgroundColor,
  onPrimary: primaryColor,
  secondary: backgroundColorSecondary,
  onSecondary: secondaryColor,
  error: Colors.blueAccent,
  onError: Colors.red,
  surface: tertiaryColor,
  onSurface: Colors.white,
);
