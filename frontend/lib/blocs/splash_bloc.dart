import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SplashEvent {}

class InitializeApp extends SplashEvent {}

abstract class SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigateToHome extends SplashState {}

class SplashNavigateToLogin extends SplashState {}

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashLoading()) {
    on<InitializeApp>(_onInitializeApp);
  }

  Future<void> _onInitializeApp(
      InitializeApp event, Emitter<SplashState> emit) async {
    try {
      // Simulate splash loading for animation
      await Future.delayed(const Duration(seconds: 3));

      // Check user login state
      final bool isLoggedIn = await _checkUserLoggedIn();

      if (isLoggedIn) {
        emit(SplashNavigateToHome());
      } else {
        emit(SplashNavigateToLogin());
      }
    } catch (e) {
      // In case of an error, fallback to Login screen
      print("Error during app initialization: ${e.toString()}");
      emit(SplashNavigateToLogin());
    }
  }

  Future<bool> _checkUserLoggedIn() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final user = FirebaseAuth.instance.currentUser;
      return user != null;
    } catch (e) {
      print("Error checking user login state: ${e.toString()}");
      return false; // Treat as logged out on error
    }
  }
}
