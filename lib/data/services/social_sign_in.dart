// ─── Social Sign In ───────────────────────────────────────────────
// Gets an identity token from Google or Apple on the phone; the API checks it
// and returns a DomEase session. Production needs the google_sign_in and
// sign_in_with_apple packages and their keys (docs/02-architecture.md,
// "Sign in"); until then the real flavors say so politely.
import 'package:domease/domain/models/failure.dart';

class SocialToken {
  const SocialToken(this.idToken, {this.name, this.email});

  final String idToken;
  final String? name;
  final String? email;
}

abstract interface class SocialSignIn {
  Future<SocialToken> google();
  Future<SocialToken> apple();
}

/// Used until the Google and Apple keys are added.
class UnconfiguredSocialSignIn implements SocialSignIn {
  const UnconfiguredSocialSignIn();

  @override
  Future<SocialToken> google() async => throw const AuthFailure('Google sign in is coming soon. Use your phone or email for now.');

  @override
  Future<SocialToken> apple() async => throw const AuthFailure('Sign in with Apple is coming soon. Use your phone or email for now.');
}
