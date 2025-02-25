import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/forgot_password_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/auth/signup_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/movie_details_screen.dart';
import 'package:frontend/screens/splash_screen.dart';

class RouteConfig {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String forgotPassword = '/forgot-password';
  static const String movieDetails = '/movieDetails';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);
      case login:
        return _fadeRoute(const LoginScreen(), settings);
      case signup:
        return _fadeRoute(const SignUpScreen(), settings);
      case home:
        return _fadeRoute(const HomeScreen(), settings);
      case forgotPassword:
        return _fadeRoute(const ForgotPasswordScreen(), settings);
      case movieDetails:
        // Handle passing arguments
        if (settings.arguments is Map<String, dynamic>) {
          final movieData = settings.arguments as Map<String, dynamic>;
          return _fadeRoute(MovieDetailScreen(movieData: movieData), settings);
        }
        return _errorRoute(settings.name);
      default:
        return _errorRoute(settings.name);
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            'No route defined for $routeName',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
