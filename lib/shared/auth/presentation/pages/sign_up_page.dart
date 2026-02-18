import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';
import '../../domain/entities/user_role.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer_panel.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_role_selector.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _orgNameController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _orgNameController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: Dispatch SignUpSubmitted event to AuthBloc
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auth implementation coming soon')),
    );
  }

  void _onGoogleSignUp() {
    // TODO: Dispatch GoogleSignInRequested event to AuthBloc
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Google Sign-Up coming soon')));
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
                    const SizedBox(height: 32),

                    // ── Role selector ──────────────────────────────────────
                    AuthRoleSelector(
                      value: _selectedRole,
                      onChanged: (role) => setState(() => _selectedRole = role),
                    ),

                    const SizedBox(height: 24),

                    // ── Full name ──────────────────────────────────────────
                    AuthTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'John Smith',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.badge_outlined),
                      autofillHints: const [AutofillHints.name],
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter your name'
                          : null,
                    ),

                    const SizedBox(height: 20),

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
                      hintText: 'Min. 8 characters',
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (v.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Confirm password ───────────────────────────────────
                    PasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Phone ──────────────────────────────────────────────
                    AuthTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hintText: '+1 234 567 8900',
                      keyboardType: TextInputType.phone,
                      textInputAction: _selectedRole == UserRole.admin
                          ? TextInputAction.next
                          : TextInputAction.done,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[\d\s\+\-\(\)]'),
                        ),
                      ],
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter your phone number'
                          : null,
                    ),

                    // ── Organization name (admin only, animated) ───────────
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _selectedRole == UserRole.admin
                          ? Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: AuthTextField(
                                controller: _orgNameController,
                                label: 'Organization Name',
                                hintText: 'Your clinic or business name',
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.done,
                                prefixIcon: const Icon(Icons.store_outlined),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Please enter your organization name'
                                    : null,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 32),

                    // ── Sign-Up button ─────────────────────────────────────
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onSignUp,
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
                          'Create Account',
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
                      onPressed: _onGoogleSignUp,
                    ),

                    const SizedBox(height: 32),

                    AuthFooterPanel(
                      message: 'Already have an account?',
                      actionLabel: 'Login',
                      onAction: () => context.go(Routes.login),
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
