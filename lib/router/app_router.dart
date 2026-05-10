import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/loans/presentation/pages/loans_page.dart';
import '../features/savings/presentation/pages/savings_page.dart';
import '../features/members/presentation/pages/members_page.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../core/widgets/luma_bar.dart';
import '../core/widgets/hud_navigation.dart';
import '../core/widgets/aurora_background.dart';
import '../core/constants/app_colors.dart';

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
    initialLocation: '/auth',
    refreshListenable: authListener,
    redirect: (context, state) {
      final isAuthenticated = authListener.isAuthenticated;
      final isOnAuth = state.matchedLocation == '/auth';

      if (!isAuthenticated && !isOnAuth) {
        return '/auth';
      }
      if (isAuthenticated && isOnAuth) {
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
            path: '/savings',
            builder: (context, state) => const SavingsPage(),
          ),
          GoRoute(
            path: '/members',
            builder: (context, state) => const MembersPage(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsPage(),
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
    if (location.startsWith('/members')) return 3;
    if (location.startsWith('/analytics')) return 4;
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
        context.go('/members');
        break;
      case 4:
        context.go('/analytics');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: AuroraBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              child,
              if (isDesktop)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Center(
                    child: HUDNavigation(
                      currentIndex: currentIndex,
                      onTap: (index) => _onItemTapped(index, context),
                      items: const [
                        HUDNavItem(
                          label: 'Home',
                          icon: Icons.dashboard_outlined,
                          activeIcon: Icons.dashboard,
                        ),
                        HUDNavItem(
                          label: 'Loans',
                          icon: Icons.account_balance_outlined,
                          activeIcon: Icons.account_balance,
                        ),
                        HUDNavItem(
                          label: 'Savings',
                          icon: Icons.savings_outlined,
                          activeIcon: Icons.savings,
                        ),
                        HUDNavItem(
                          label: 'Members',
                          icon: Icons.people_outlined,
                          activeIcon: Icons.people,
                        ),
                        HUDNavItem(
                          label: 'Analytics',
                          icon: Icons.analytics_outlined,
                          activeIcon: Icons.analytics,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : PremiumBottomNav(
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(index, context),
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