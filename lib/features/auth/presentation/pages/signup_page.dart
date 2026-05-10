import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
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
        SnackBar(
          content: const Text('Please agree to the terms and conditions'),
          backgroundColor: Theme.of(context).colorScheme.error,
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
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(auth.authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  _buildLogo(theme, primary, secondary),
                  const SizedBox(height: AppSpacing.lg),
                  _buildWelcomeText(theme),
                  const SizedBox(height: AppSpacing.xl),
                  _buildForm(isLoading, theme, isDark, primary),
                  const SizedBox(height: AppSpacing.md),
                  _buildTermsCheckbox(theme, primary, secondary),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSignUpButton(isLoading, primary, secondary),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSignInLink(theme, primary),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme, Color primary, Color secondary) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, secondary],
        ),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 0),
        ],
      ),
      child: const Icon(Icons.app_registration, size: 36, color: Colors.white),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildWelcomeText(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Create Account',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Join MicroFlow Pro today',
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildForm(bool isLoading, ThemeData theme, bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outlined, size: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined, size: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Phone is required';
                if (value.length != 10) return 'Enter a valid 10-digit phone';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password is required';
                if (value.length < 8) return 'Password must be at least 8 characters';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please confirm your password';
                if (value != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildTermsCheckbox(ThemeData theme, Color primary, Color secondary) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: AnimatedContainer(
            duration: AppSpacing.animationFast,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _agreedToTerms ? secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreedToTerms ? secondary : (theme.textTheme.bodySmall?.color ?? Colors.grey),
                width: 1.5,
              ),
            ),
            child: _agreedToTerms ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'I agree to the Terms of Service and Privacy Policy',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(bool isLoading, Color primary, Color secondary) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSignUp,
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ),
    );
  }

  Widget _buildSignInLink(ThemeData theme, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account?', style: theme.textTheme.bodyMedium),
        TextButton(
          onPressed: widget.onSignInTap,
          child: Text('Sign In', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}