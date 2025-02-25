import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/config/route_config.dart';
import 'package:lottie/lottie.dart';
import '../blocs/splash_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToHome) {
            Navigator.pushReplacementNamed(context, RouteConfig.home);
          } else if (state is SplashNavigateToLogin) {
            Navigator.pushReplacementNamed(context, RouteConfig.login);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Centered animation
            Center(
              child: Lottie.asset(
                'assets/animations/splash_screen_animation.json', // Ensure it's JSON
                animate: true,
                repeat: true, // Keeps looping
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "MovieMate🎬",
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
