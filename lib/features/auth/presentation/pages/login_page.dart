import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error ?? 'Login failed'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(auth.authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ─── Logo ───
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.account_balance_rounded, size: 38, color: Colors.white),
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 28),

                  // ─── Welcome ───
                  Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5))
                    .animate().fadeIn(delay: 150.ms).slideY(begin: 0.15, end: 0),
                  const SizedBox(height: 6),
                  Text('Sign in to continue', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color))
                    .animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: 36),

                  // ─── Form Card ───
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
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
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Forgot Password?', style: TextStyle(color: primary, fontWeight: FontWeight.w500, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            child: isLoading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                        ),
                      ]),
                    ),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Don't have an account?", style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: widget.onSignUpTap,
                      child: Text('Sign Up', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}