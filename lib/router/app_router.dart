import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/loans/presentation/pages/loans_page.dart';
import '../features/savings/presentation/pages/savings_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../core/widgets/hud_navigation.dart';
import '../features/loans/presentation/pages/loan_detail_page.dart';
import '../features/loans/presentation/pages/new_loan_page.dart';
import '../features/savings/presentation/pages/new_recurring_saving_page.dart';
import '../features/users/presentation/pages/users_page.dart';
import '../features/users/presentation/pages/new_user_page.dart';

class AuthRedirectListener extends ChangeNotifier {
  final Ref ref;

  AuthRedirectListener(this.ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      notifyListeners();
    });
  }

  bool get isAuthenticated =>
      ref.read(authProvider).status == AuthStatus.authenticated;
}

final authRedirectListenerProvider = Provider<AuthRedirectListener>((ref) {
  return AuthRedirectListener(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final authListener = ref.watch(authRedirectListenerProvider);

  return GoRouter(
    initialLocation: '/loans',
    refreshListenable: authListener,
    redirect: (context, state) {
      // Temporarily bypass auth for rapid UI testing
      return null;
    },

    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthShell(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePageContent(),
          ),
          GoRoute(
            path: '/loans',
            builder: (context, state) => const LoansPage(),
          ),
          GoRoute(
            path: '/loans/new',
            builder: (context, state) => const NewLoanPage(),
          ),
          GoRoute(
            path: '/loans/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return LoanDetailPage(loanId: id);
            },
          ),
          GoRoute(
            path: '/savings',
            builder: (context, state) => const SavingsPage(),
          ),
          GoRoute(
            path: '/savings/new',
            builder: (context, state) => const NewRecurringSavingPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/users/new',
            builder: (context, state) => const NewUserPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});

class AuthShell extends StatefulWidget {
  const AuthShell({super.key});

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginPage(
        onSignUpTap: () => setState(() => _showLogin = false),
      );
    } else {
      return SignUpPage(
        onSignInTap: () => setState(() => _showLogin = true),
      );
    }
  }
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/loans')) return 1;
    if (location.startsWith('/savings')) return 2;
    if (location.startsWith('/users')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/loans');
        break;
      case 2:
        context.go('/savings');
        break;
      case 3:
        context.go('/users');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final currentIndex = _calculateSelectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          child,
          // Desktop: top HUD navigation
          if (isDesktop)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Center(
                child: HUDNavigation(
                  currentIndex: currentIndex,
                  onTap: (index) => _onItemTapped(index, context),
                  items: const [
                    HUDNavItem(
                      label: 'Dashboard',
                      icon: Icons.grid_view_outlined,
                      activeIcon: Icons.grid_view_rounded,
                    ),
                    HUDNavItem(
                      label: 'Loans',
                      icon: Icons.account_balance_outlined,
                      activeIcon: Icons.account_balance_rounded,
                    ),
                    HUDNavItem(
                      label: 'Savings',
                      icon: Icons.account_balance_wallet_outlined,
                      activeIcon: Icons.account_balance_wallet_rounded,
                    ),
                    HUDNavItem(
                      label: 'Users',
                      icon: Icons.manage_accounts_outlined,
                      activeIcon: Icons.manage_accounts_rounded,
                    ),
                    HUDNavItem(
                      label: 'Settings',
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings_rounded,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // Mobile: iOS-style bottom tab bar
      bottomNavigationBar: isDesktop
          ? null
          : _IOSBottomTabBar(
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(index, context),
              isDark: isDark,
            ),
    );
  }
}

/// iOS-style bottom tab bar with frosted glass effect.
class _IOSBottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _IOSBottomTabBar({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.35);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
                width: 0.33,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TabItem(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    selectedColor: primary,
                    inactiveColor: inactiveColor,
                    onTap: () => onTap(0),
                  ),
                  _TabItem(
                    icon: Icons.account_balance_outlined,
                    activeIcon: Icons.account_balance_rounded,
                    label: 'Loans',
                    isSelected: currentIndex == 1,
                    selectedColor: primary,
                    inactiveColor: inactiveColor,
                    onTap: () => onTap(1),
                  ),
                  _TabItem(
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet_rounded,
                    label: 'Savings',
                    isSelected: currentIndex == 2,
                    selectedColor: primary,
                    inactiveColor: inactiveColor,
                    onTap: () => onTap(2),
                  ),
                  _TabItem(
                    icon: Icons.manage_accounts_outlined,
                    activeIcon: Icons.manage_accounts_rounded,
                    label: 'Users',
                    isSelected: currentIndex == 3,
                    selectedColor: primary,
                    inactiveColor: inactiveColor,
                    onTap: () => onTap(3),
                  ),
                  _TabItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'Settings',
                    isSelected: currentIndex == 4,
                    selectedColor: primary,
                    inactiveColor: inactiveColor,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? selectedColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage(
      onViewAllLoans: () {},
      onViewAllSavings: () {},
      onQuickAction: () {},
    );
  }
}