// ─── Router ───────────────────────────────────────────────────────
// go_router. The splash sends a new person to Welcome, a signed in person
// without a home to Setup, and everyone else to Today. The four tabs keep
// their own stacks; Premium opens over everything.
import 'package:go_router/go_router.dart';

import 'package:domease/domain/models/legal.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/about/widgets/about_screen.dart';
import 'package:domease/ui/answers/widgets/answers_screen.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/auth/widgets/account_screen.dart';
import 'package:domease/ui/auth/widgets/code_screen.dart';
import 'package:domease/ui/auth/widgets/email_screen.dart';
import 'package:domease/ui/auth/widgets/forgot_password_screen.dart';
import 'package:domease/ui/auth/widgets/phone_screen.dart';
import 'package:domease/ui/clean/widgets/clean_screen.dart';
import 'package:domease/ui/convert/widgets/convert_screen.dart';
import 'package:domease/ui/core/ui/app_shell.dart';
import 'package:domease/ui/help/widgets/help_screen.dart';
import 'package:domease/ui/house_help/widgets/house_help_screen.dart';
import 'package:domease/ui/household/widgets/household_screen.dart';
import 'package:domease/ui/legal/widgets/legal_screen.dart';
import 'package:domease/ui/meals/widgets/meals_screen.dart';
import 'package:domease/ui/meals/widgets/recipe_screen.dart';
import 'package:domease/ui/onboarding/widgets/onboarding_screen.dart';
import 'package:domease/ui/premium/widgets/premium_screen.dart';
import 'package:domease/ui/profile/widgets/profile_screen.dart';
import 'package:domease/ui/settings/widgets/settings_screen.dart';
import 'package:domease/ui/setup/widgets/join_screen.dart';
import 'package:domease/ui/setup/widgets/setup_screen.dart';
import 'package:domease/ui/shop/widgets/shop_screen.dart';
import 'package:domease/ui/splash/widgets/splash_screen.dart';
import 'package:domease/ui/today/widgets/today_screen.dart';
import 'package:domease/ui/welcome/widgets/welcome_screen.dart';
import 'package:domease/ui/you/widgets/you_screen.dart';

GoRouter buildRouter() => GoRouter(
      initialLocation: Routes.splash,
      routes: [
        GoRoute(path: Routes.splash, builder: (context, state) => const SplashScreen()),
        GoRoute(path: Routes.welcome, builder: (context, state) => const WelcomeScreen()),
        GoRoute(
          path: Routes.setup,
          builder: (context, state) => const SetupScreen(),
          routes: [
            GoRoute(path: 'home', builder: (context, state) => const OnboardingScreen()),
            GoRoute(path: 'join', builder: (context, state) => const JoinScreen()),
          ],
        ),
        GoRoute(path: Routes.premium, builder: (context, state) => const PremiumScreen()),
        GoRoute(
          path: '/legal/:id',
          builder: (context, state) =>
              LegalScreen(id: LegalDocId.values.firstWhere((d) => d.name == state.pathParameters['id'], orElse: () => LegalDocId.terms)),
        ),
        GoRoute(
          path: Routes.account,
          builder: (context, state) => AccountScreen(mode: _mode(state)),
          routes: [
            GoRoute(path: 'phone', builder: (context, state) => const PhoneScreen()),
            GoRoute(path: 'code', builder: (context, state) => CodeScreen(phone: state.uri.queryParameters['phone'] ?? '')),
            GoRoute(path: 'email', builder: (context, state) => EmailScreen(mode: _mode(state))),
            GoRoute(path: 'forgot', builder: (context, state) => const ForgotPasswordScreen()),
          ],
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.today,
                builder: (context, state) => const TodayScreen(),
                routes: [
                  GoRoute(path: 'convert', builder: (context, state) => const ConvertScreen()),
                  GoRoute(path: 'house-help', builder: (context, state) => const HouseHelpScreen()),
                  GoRoute(path: 'household', builder: (context, state) => const HouseholdScreen()),
                  GoRoute(
                    path: 'you',
                    builder: (context, state) => const YouScreen(),
                    routes: [
                      GoRoute(path: 'profile', builder: (context, state) => const ProfileScreen()),
                      GoRoute(path: 'settings', builder: (context, state) => const SettingsScreen()),
                      GoRoute(path: 'answers', builder: (context, state) => const AnswersScreen()),
                      GoRoute(path: 'help', builder: (context, state) => const HelpScreen()),
                      GoRoute(path: 'about', builder: (context, state) => const AboutScreen()),
                    ],
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.meals,
                builder: (context, state) => const MealsScreen(),
                routes: [
                  GoRoute(path: 'recipe/:id', builder: (context, state) => RecipeScreen(id: state.pathParameters['id']!)),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [GoRoute(path: Routes.clean, builder: (context, state) => const CleanScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: Routes.shop, builder: (context, state) => const ShopScreen())]),
          ],
        ),
      ],
    );

/// `?mode=login` opens the log in version; anything else is sign up.
AuthMode _mode(GoRouterState state) => state.uri.queryParameters['mode'] == 'login' ? AuthMode.logIn : AuthMode.signUp;
