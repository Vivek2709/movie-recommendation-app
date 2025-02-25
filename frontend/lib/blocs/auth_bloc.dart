import 'package:equatable/equatable.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String? fcmToken;

  LoginRequested(this.email, this.password, this.fcmToken);

  @override
  List<Object?> get props => [email, password, fcmToken];
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final List<String> genres;
  final List<String> themes;

  SignupRequested(
      this.email, this.password, this.displayName, this.genres, this.themes);

  @override
  List<Object?> get props => [email, password, displayName, genres, themes];
}

class LogoutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

//* States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  final String uid;

  AuthSuccess(this.message, this.uid);

  @override
  List<Object?> get props => [message, uid];
}

class AuthFailure extends AuthState {
  final String errorMessage;
  AuthFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

//* Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    //* Handle Login
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        User user = await authRepository.login(
          email: event.email,
          password: event.password,
          fcmToken: event.fcmToken,
        );
        emit(AuthSuccess("Login Successful", user.uid));
      } catch (e) {
        emit(AuthFailure(e.toString().isNotEmpty
            ? e.toString()
            : "An unexpected error occurred during login."));
      }
    });

    //* Handle Signup
    on<SignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        User user = await authRepository.signup(
          email: event.email,
          password: event.password,
          displayName: event.displayName,
          genres: event.genres,
          themes: event.themes,
        );
        emit(AuthSuccess('Sign Up Successful', user.uid));
      } catch (e) {
        emit(AuthFailure(e.toString().isNotEmpty
            ? e.toString()
            : "An unexpected error occurred during signup."));
      }
    });

    //* Handle Logout
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.logout();
        emit(AuthSuccess("Logout Successful", ""));
      } catch (e) {
        emit(AuthFailure(e.toString().isNotEmpty
            ? e.toString()
            : "An unexpected error occurred during logout."));
      }
    });

    //* Handle Forgot Password
    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.forgotPassword(event.email);
        emit(AuthSuccess("Password reset email sent successfully", ""));
      } catch (e) {
        emit(AuthFailure("Failed to send reset email: ${e.toString()}"));
      }
    });
  }
}
