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

class SignUpPage extends ConsumerStatefulWidget {
  final VoidCallback onSignInTap;

  const SignUpPage({super.key, required this.onSignInTap});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final success = await ref.read(auth.authProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      final error = ref.read(auth.authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Sign up failed'),
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
                const SizedBox(height: AppSpacing.xl),
                _buildLogo(),
                const SizedBox(height: AppSpacing.lg),
                _buildWelcomeText(),
                const SizedBox(height: AppSpacing.xl),
                _buildForm(isLoading),
                const SizedBox(height: AppSpacing.md),
                _buildTermsCheckbox(),
                const SizedBox(height: AppSpacing.lg),
                _buildSignUpButton(isLoading),
                const SizedBox(height: AppSpacing.lg),
                _buildSignInLink(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
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
        Icons.app_registration,
        size: 36,
        color: AppColors.textPrimary,
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Join MicroFlow Pro today',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
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
                  label: 'FULL NAME',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  prefixIcon: const Icon(
                    Icons.person_outlined,
                    color: AppColors.textMuted,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
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
                  label: 'PHONE',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.textMuted,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone is required';
                    }
                    if (value.length != 10) {
                      return 'Enter a valid 10-digit phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                GlassTextField(
                  label: 'PASSWORD',
                  hint: 'Create a password',
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
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                GlassTextField(
                  label: 'CONFIRM PASSWORD',
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(
                    Icons.lock_outlined,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
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

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: AnimatedContainer(
            duration: AppSpacing.animationFast,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _agreedToTerms
                  ? AppColors.primaryIndigo
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreedToTerms
                    ? AppColors.primaryIndigo
                    : AppColors.textMuted,
                width: 1.5,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.textPrimary,
                  )
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'I agree to the Terms of Service and Privacy Policy',
            style: TextStyle(
              color: _agreedToTerms
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeightLg,
      child: GlassButton(
        text: 'Create Account',
        isLoading: isLoading,
        icon: Icons.app_registration,
        gradientColors: const [
          AppColors.primaryIndigo,
          AppColors.primaryPurple,
        ],
        onPressed: _handleSignUp,
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: widget.onSignInTap,
          child: const Text(
            'Sign In',
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