import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/widgets/bars/custom_app_bar.dart';
import 'package:frontend/widgets/buttons/custom_button.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:frontend/widgets/dialogs/custom_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Forgot Password",
        showBackButton: true,
        onBack: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            print("hello");
          } else {
            print("No screen to pop! Ensure it's pushed correctly.");
          }
        },
        actions: [
          //* logout button in appbar
          // IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () => Navigator.canPop(context),
          // )
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            CustomSnackbar.show(context: context, message: state.message);
          } else if (state is AuthFailure) {
            CustomSnackbar.show(
                context: context, message: state.errorMessage, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Password gone missing? We've got you covered",
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  controller: emailController,
                  hintText: "Entet your email",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                CustomButton(
                    text: "Send Reset Email",
                    isLoading: isLoading,
                    onPressed: () {
                      final email = emailController.text.trim();
                      if (email.isEmpty) {
                        CustomSnackbar.show(
                            context: context,
                            message: "Email is required",
                            isError: true);
                        return;
                      }
                      context
                          .read<AuthBloc>()
                          .add(ForgotPasswordRequested(email));
                    }),
              ],
            ),
          );
        },
      ),
    );
  }
}
