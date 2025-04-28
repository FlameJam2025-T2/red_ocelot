import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:red_ocelot/config/keys.dart';
import 'package:red_ocelot/red_ocelot_game.dart';
import 'package:red_ocelot/ui/pallette.dart';

class SplashScreen extends StatefulWidget {
  final RedOcelotGame game;

  const SplashScreen({required this.game, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Animation value for the pulsing "Press any key" text
  late Animation<double> _pulseAnimation;

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animController.forward();
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleInteraction() {
    if (_isExiting) return;

    setState(() {
      _isExiting = true;
    });

    Timer(const Duration(milliseconds: 300), () {
      widget.game.overlays.remove(splashKey);
      widget.game.overlays.add(mainMenuKey);
      widget.game.audioManager.init().then((_) {
        widget.game.audioManager.playBGM();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (KeyEvent event) {
        if (event is KeyUpEvent) {
          _handleInteraction();
        }
      },
      child: GestureDetector(
        onTap: _handleInteraction,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColorSecondary,
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                backgroundColorSecondary,
                const Color(0xFF2B004A),
                Colors.black,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: AnimatedOpacity(
            opacity: _isExiting ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _opacityAnimation.value,
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: _GameTitle(),
                      ),

                      SizedBox(height: size.height * 0.1),

                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _pulseAnimation.value,
                            child: Transform.scale(
                              scale: _pulseAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: const Text(
                          'PRESS ANY KEY OR TAP TO CONTINUE',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [primaryColor, const Color(0xFFFF0099), secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
          child: const Text(
            'RED OCELOT',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3.0,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(3, 3),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),
        const Text(
          'Race to claim your space',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: Colors.white70,
            letterSpacing: 8.0,
          ),
        ),
      ],
    );
  }
}
