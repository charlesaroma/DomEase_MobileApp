// ─── Router ───────────────────────────────────────────────────────
// go_router: the splash first, then Today. Meals, Clean, Shop and the
// household profile join here as their screens are built (docs/02-architecture.md).
import 'package:go_router/go_router.dart';

import 'package:domease/routing/routes.dart';
import 'package:domease/ui/splash/widgets/splash_screen.dart';
import 'package:domease/ui/today/widgets/today_screen.dart';

final appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(path: Routes.splash, builder: (context, state) => const SplashScreen()),
    GoRoute(path: Routes.today, builder: (context, state) => const TodayScreen()),
  ],
);
