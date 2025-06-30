// lib/screen/splash_screen.dart

import 'package:flutter/material.dart';
import '../route/app_routes.dart';
import '../widget/animated_logo.dart';
import '../widget/loading_indicator.dart';
import '../widget/loading_text.dart';
import '../util/app_constants.dart';
import '../util/gradient_utils.dart';
import 'beranda.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _circleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _circleScaleAnimation;
  late Animation<double> _circleFadeAnimation;

  int currentStep = 0;
  final int totalSteps = AppConstants.totalLoadingSteps;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimation();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _circleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _circleScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: Curves.easeInOut,
      ),
    );

    _circleFadeAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mainController.forward();

    for (int i = 0; i < totalSteps; i++) {
      if (!mounted) return;
      setState(() => currentStep = i);
      await _circleController.forward();
      if (!mounted) return;
      await _circleController.reverse();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _circleController]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: GradientUtils.splashGradient,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: AnimatedLogo(
                        scaleAnimation: _circleScaleAnimation,
                        fadeAnimation: _circleFadeAnimation,
                        currentStep: currentStep,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: LoadingIndicator(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                  ),
                ),
                const SizedBox(height: 40),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Column(
                      children: [
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          AppConstants.appSlogan,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: LoadingText(currentStep: currentStep),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
