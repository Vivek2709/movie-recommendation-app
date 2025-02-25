import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/widgets/bars/custom_app_bar.dart';
import 'package:frontend/widgets/buttons/custom_button.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:frontend/widgets/dialogs/custom_snackbar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController genresController = TextEditingController();
  final TextEditingController themesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(title: "Sign Up"),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              CustomSnackbar.show(
                context: context,
                message: "Sign Up Successful!",
              );
              Navigator.pop(context);
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

            return Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Create an Account",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sign up to start discovering amazing movies!",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: emailController,
                      hintText: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Enter your password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: displayNameController,
                      hintText: "Enter your display name",
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: genresController,
                      hintText: "Enter your favorite genres (comma-separated)",
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: themesController,
                      hintText: "Enter your favorite themes (comma-separated)",
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: "Sign Up",
                      isLoading: isLoading,
                      onPressed: () {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();
                        final displayName = displayNameController.text.trim();
                        final genres = genresController.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList();
                        final themes = themesController.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList();
                        if (email.isEmpty ||
                            password.isEmpty ||
                            displayName.isEmpty ||
                            genres.isEmpty ||
                            themes.isEmpty) {
                          CustomSnackbar.show(
                            context: context,
                            message: "All fields are required",
                            isError: true,
                          );
                          return;
                        }
                        context.read<AuthBloc>().add(
                              SignupRequested(
                                  email, password, displayName, genres, themes),
                            );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
