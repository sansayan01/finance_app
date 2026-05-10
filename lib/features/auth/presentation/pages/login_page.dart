import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../providers/auth_provider.dart';

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
    final success = await ref.read(authProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      final error = ref.read(authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error ?? 'Login failed'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your email first to reset password'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final success = await ref.read(authProvider.notifier).resetPassword(email);
    if (success && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.9),
          title: const Text('Reset Link Sent', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text('A password reset link has been sent to $email. Please check your inbox.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AuroraBackground(
        child: Stack(
          children: [
            // ── Deep Blur Overlay ──
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),
          ),

          // ── Particle System ──
          ...List.generate(12, (i) => Positioned(
            top: (i * 150.0) % MediaQuery.of(context).size.height,
            left: (i * 100.0) % MediaQuery.of(context).size.width,
            child: Container(
              width: 2 + (i % 3).toDouble(),
              height: 2 + (i % 3).toDouble(),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: primary.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat())
             .moveY(begin: 0, end: -100, duration: (5000 + i * 1000).ms, curve: Curves.linear)
             .fadeOut(duration: 1000.ms),
          )),

          // ── Content ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      // ── Header Section ──
                      const SizedBox(height: 20),
                      _buildIOSLogo(primary),
                      const SizedBox(height: 40),
                      
                      // ── Glassmorphic Login Container ──
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? Colors.white.withValues(alpha: 0.04) 
                                  : Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.4),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sign In',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                      fontSize: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Enter your workspace credentials',
                                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 14, letterSpacing: -0.2),
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Email Field
                                  _buildIOSInput(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.alternate_email_rounded,
                                    isDark: isDark,
                                    primary: primary,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.only(left: 48),
                                    child: Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                                  ),
                                  
                                  // Password Field
                                  _buildIOSInput(
                                    controller: _passwordController,
                                    label: 'Password',
                                    icon: Icons.lock_outline_rounded,
                                    isDark: isDark,
                                    primary: primary,
                                    obscureText: _obscurePassword,
                                    suffix: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      color: isDark ? Colors.white38 : Colors.black38,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Login Button
                                  _buildPremiumButton(isLoading, primary, _handleLogin),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Forgot Password
                                  Center(
                                    child: TextButton(
                                      onPressed: _handleForgotPassword,
                                      style: TextButton.styleFrom(
                                        foregroundColor: primary.withValues(alpha: 0.8),
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: -0.2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.98, 0.98), curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 48),
                      
                      // Invitation Badge
                      _buildSecurityBadge(primary, isDark),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildIOSLogo(Color primary) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Center(
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: -2),
            ],
          ),
          child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 28),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .shimmer(duration: 3.seconds, color: Colors.white24)
     .moveY(begin: -4, end: 4, duration: 2.seconds, curve: Curves.easeInOut);
  }

  Widget _buildIOSInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color primary,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, size: 20, color: primary.withValues(alpha: 0.7)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPremiumButton(bool isLoading, Color primary, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: primary.withValues(alpha: 0.5),
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.5)),
      ),
    );
  }

  Widget _buildSecurityBadge(Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: primary.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, size: 14, color: primary.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text(
            'ENTERPRISE SECURITY ACTIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }
}