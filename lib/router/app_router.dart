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
import '../features/settings/presentation/pages/profile_page.dart';
import '../features/settings/presentation/pages/activity_logs_page.dart';
import '../core/widgets/hud_navigation.dart';
import '../features/loans/presentation/pages/loan_detail_page.dart';
import '../features/loans/presentation/pages/new_loan_page.dart';
import '../features/savings/presentation/pages/new_recurring_saving_page.dart';
import '../features/savings/presentation/pages/saving_detail_page.dart';
import '../features/users/presentation/pages/users_page.dart';
import '../features/users/presentation/pages/new_user_page.dart';
import '../features/users/presentation/pages/user_details_page.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../features/home/presentation/pages/search_page.dart';
import '../features/home/presentation/pages/notifications_page.dart';
import '../features/transactions/presentation/pages/transactions_page.dart';

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
      final authStatus = ref.read(authProvider).status;
      final isAuthenticated = authStatus == AuthStatus.authenticated;
      final isAuthPath = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isAuthPath) {
        return '/auth';
      }

      if (isAuthenticated && isAuthPath) {
        return '/';
      }

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
            path: '/savings/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return SavingDetailPage(savingId: id);
            },
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
            path: '/users/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return UserDetailsPage(userId: id);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
              GoRoute(
                path: 'logs',
                builder: (context, state) => const ActivityLogsPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsPage(),
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
      case 0: context.go('/'); break;
      case 1: context.go('/loans'); break;
      case 2: context.go('/savings'); break;
      case 3: context.go('/users'); break;
      case 4: context.go('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final useHudNav = MediaQuery.of(context).size.width >= 600;
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          child,
          if (useHudNav)
            Positioned(
              left: 0, right: 0, top: 0,
              child: Center(
                child: HUDNavigation(
                  currentIndex: currentIndex,
                  onTap: (index) => _onItemTapped(index, context),
                  items: const [
                    HUDNavItem(label: 'Dashboard', icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded),
                    HUDNavItem(label: 'Loans', icon: Icons.account_balance_outlined, activeIcon: Icons.account_balance_rounded),
                    HUDNavItem(label: 'Savings', icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded),
                    HUDNavItem(label: 'Users', icon: Icons.manage_accounts_outlined, activeIcon: Icons.manage_accounts_rounded),
                    HUDNavItem(label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: useHudNav
          ? null
          : _PremiumBottomBar(
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(index, context),

            ),
    );
  }
}

class _PremiumBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3E3E4A).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.15 : 0.4),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.5),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(index: 0, icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, label: 'Home', currentIndex: currentIndex, primary: primary, isDark: isDark, onTap: onTap),
                  _NavItem(index: 1, icon: Icons.account_balance_outlined, activeIcon: Icons.account_balance_rounded, label: 'Loans', currentIndex: currentIndex, primary: primary, isDark: isDark, onTap: onTap),
                  _NavItem(index: 2, icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Savings', currentIndex: currentIndex, primary: primary, isDark: isDark, onTap: onTap),
                  _NavItem(index: 3, icon: Icons.manage_accounts_outlined, activeIcon: Icons.manage_accounts_rounded, label: 'Users', currentIndex: currentIndex, primary: primary, isDark: isDark, onTap: onTap),
                  _NavItem(index: 4, icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings', currentIndex: currentIndex, primary: primary, isDark: isDark, onTap: onTap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int currentIndex;
  final Color primary;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _NavItem({required this.index, required this.icon, required this.activeIcon, required this.label, required this.currentIndex, required this.primary, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    final inactiveColor = isDark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.28);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: isDark ? 0.15 : 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.1 : 1.0,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? primary : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primary : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
      onViewAllLoans: () => context.go('/loans'),
      onViewAllSavings: () => context.go('/savings'),
      onQuickAction: () {},
    );
  }
}