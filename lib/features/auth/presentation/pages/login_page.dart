import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/aurora_background.dart';

import '../providers/auth_provider.dart';
import '../providers/auth_provider.dart' as auth;

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback onSignUpTap;

  const LoginPage({super.key, required this.onSignUpTap});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(auth.authProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      final error = ref.read(auth.authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(auth.authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: AuroraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                _buildLogo(),
                const SizedBox(height: AppSpacing.xxl),
                _buildWelcomeText(),
                const SizedBox(height: AppSpacing.xxl),
                _buildForm(isLoading),
                const SizedBox(height: AppSpacing.lg),
                _buildForgotPassword(),
                const SizedBox(height: AppSpacing.lg),
                _buildLoginButton(isLoading),
                const SizedBox(height: AppSpacing.xl),
                _buildSignUpLink(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryIndigo.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Icon(
        Icons.account_balance,
        size: 48,
        color: AppColors.textPrimary,
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Sign in to continue to MicroFlow Pro',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildForm(bool isLoading) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GlassTextField(
                  label: 'EMAIL',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.textMuted,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                GlassTextField(
                  label: 'PASSWORD',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(
                    Icons.lock_outlined,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppColors.primaryTeal,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeightLg,
      child: GlassButton(
        text: 'Sign In',
        isLoading: isLoading,
        icon: Icons.login,
        gradientColors: const [
          AppColors.primaryIndigo,
          AppColors.primaryPurple,
        ],
        onPressed: _handleLogin,
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: widget.onSignUpTap,
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}