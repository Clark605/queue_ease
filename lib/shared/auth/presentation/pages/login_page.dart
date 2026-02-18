import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer_panel.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: Dispatch LoginSubmitted event to AuthBloc
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auth implementation coming soon')),
    );
  }

  void _onGoogleSignIn() {
    // TODO: Dispatch GoogleSignInRequested event to AuthBloc
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Google Sign-In coming soon')));
  }

  void _onForgotPassword() {
    // TODO: Navigate to forgot-password screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password reset coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(),
                    const SizedBox(height: 36),

                    // ── Email ──────────────────────────────────────────────
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                      autofillHints: const [AutofillHints.email],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Password ───────────────────────────────────────────
                    PasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      labelSuffix: TextButton(
                        onPressed: _onForgotPassword,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter your password'
                          : null,
                    ),

                    const SizedBox(height: 32),

                    // ── Login button ───────────────────────────────────────
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onLogin,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: AppColors.primary.withValues(
                            alpha: 0.25,
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const AuthDivider(),
                    const SizedBox(height: 24),

                    // ── Google ─────────────────────────────────────────────
                    GoogleSignInButton(
                      label: 'Continue with Google',
                      onPressed: _onGoogleSignIn,
                    ),

                    const SizedBox(height: 32),

                    AuthFooterPanel(
                      message: "Don't have an account?",
                      actionLabel: 'Create account',
                      onAction: () => context.go(Routes.signUp),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
