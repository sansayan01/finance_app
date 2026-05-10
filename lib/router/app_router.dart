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
            path: '/members',
            builder: (context, state) => const MembersPage(),
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
    if (location.startsWith('/loans')) return 2;
    if (location.startsWith('/savings')) return 3;
    if (location.startsWith('/members')) return 4;
    if (location.startsWith('/users')) return 5;
    if (location.startsWith('/analytics')) return 1;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/analytics');
        break;
      case 2:
        context.go('/loans');
        break;
      case 3:
        context.go('/savings');
        break;
      case 4:
        context.go('/members');
        break;
      case 5:
        context.go('/users');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          child,
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
                      label: 'Analytics',
                      icon: Icons.history_outlined,
                      activeIcon: Icons.history_rounded,
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
                      label: 'Members',
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
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
                    HUDNavItem(
                      label: 'Theme',
                      icon: Icons.dark_mode_outlined,
                      activeIcon: Icons.dark_mode_rounded,
                    ),
                    HUDNavItem(
                      label: 'Logout',
                      icon: Icons.logout_rounded,
                      activeIcon: Icons.logout_rounded,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: null,
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