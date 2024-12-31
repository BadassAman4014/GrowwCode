import 'package:flutter/material.dart';
import 'dart:math';
import '../H2.dart';
import '../Homepage.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: AnimatedWelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AnimatedWelcomeScreen extends StatefulWidget {
  @override
  _AnimatedWelcomeScreenState createState() => _AnimatedWelcomeScreenState();
}

class _AnimatedWelcomeScreenState extends State<AnimatedWelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Text animation (slide up and fade)
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Button animation (slide up and fade)
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4CAF50),
                  Color(0xFF81C784),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoOpacityAnimation.value.clamp(0.0, 1.0),
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/logo.png",
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Animated Tagline
                  Transform.translate(
                    offset: Offset(0, 50 * (1 - _textAnimation.value)),
                    child: Opacity(
                      opacity: _textAnimation.value.clamp(0.0, 1.0),
                      child: Text(
                        "Your Ultimate\nSolution Platform",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black26,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 50),

                  // Animated Button
                  Transform.translate(
                    offset: Offset(0, 50 * (1 - _buttonAnimation.value)),
                    child: Opacity(
                      opacity: _buttonAnimation.value.clamp(0.0, 1.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen(language: '',)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Get Started",
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}