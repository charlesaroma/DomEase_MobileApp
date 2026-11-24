// ─── Routes ───────────────────────────────────────────────────────
// Every path as a constant, so a typo is a compile error. The first run
// goes: splash, welcome, account, set up or join, the questions, Today.
import 'package:domease/domain/models/legal.dart';

abstract final class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const premium = '/premium';

  // ── Account ──
  static const account = '/account';
  static const accountPhone = '/account/phone';
  static const accountCode = '/account/code';
  static const accountEmail = '/account/email';
  static const accountForgot = '/account/forgot';
  static const signUp = '/account?mode=signup';
  static const logIn = '/account?mode=login';

  // ── A home for the account ──
  static const setup = '/setup';
  static const questions = '/setup/home';
  static const join = '/setup/join';

  // ── The four tabs ──
  static const today = '/today';
  static const meals = '/meals';
  static const clean = '/clean';
  static const shop = '/shop';

  // ── Inside a tab ──
  static const convert = '/today/convert';
  static const houseHelp = '/today/house-help';
  static const household = '/today/household';
  static String recipe(String id) => '/meals/recipe/$id';

  // ── You: the person, their home, the app ──
  static const you = '/today/you';
  static const profile = '/today/you/profile';
  static const settings = '/today/you/settings';
  static const answers = '/today/you/answers';
  static const help = '/today/you/help';
  static const about = '/today/you/about';

  /// Readable before signing in too (the sign in screens link to it).
  static String legal(LegalDocId id) => '/legal/${id.name}';
}
