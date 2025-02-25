import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/widgets/bars/custom_app_bar.dart';
import 'package:frontend/widgets/buttons/custom_button.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:frontend/widgets/dialogs/custom_snackbar.dart';
import 'package:logger/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Login"),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            CustomSnackbar.show(context: context, message: state.message);
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthFailure) {
            CustomSnackbar.show(
              context: context,
              message: state.errorMessage,
              isError: true,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(16).copyWith(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                //* 🔥 Animated Login Text
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    "Log In to start discovering amazing movies!",
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                //* Email Field
                CustomTextField(
                  controller: emailController,
                  hintText: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                //* Password Field
                CustomTextField(
                  controller: passwordController,
                  hintText: "Enter your password",
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                //* Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                //* Login Button
                CustomButton(
                  text: 'Login',
                  isLoading: isLoading,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 24),

                //* Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  //* 🔹 Handle Login Action
  void _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    //* Validation
    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      CustomSnackbar.show(
        context: context,
        message: "Email and password are required",
        isError: true,
      );
      return;
    }

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (!mounted) return;
      context.read<AuthBloc>().add(LoginRequested(email, password, fcmToken));
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context: context,
        message: "Failed to fetch FCM token: ${e.toString()}",
        isError: true,
      );
    }
  }
}
