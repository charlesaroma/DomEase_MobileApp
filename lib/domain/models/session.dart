// ─── Session ──────────────────────────────────────────────────────
// Who is signed in on this phone, and how (PRD 7.2: tokens issued by the
// Node.js server).

enum SignInMethod { google, apple, phone, email }

class Session {
  const Session({required this.userId, required this.token, required this.method, this.name, this.email, this.phone});

  final String userId;

  /// The API's JWT. Sent on every request by the ApiClient.
  final String token;
  final SignInMethod method;
  final String? name;
  final String? email;
  final String? phone;

  /// What to show as "Signed in as …".
  String get label => email ?? phone ?? name ?? 'your account';

  /// Two letters for the avatar: "Sarah Namukasa" is SN.
  String get initials {
    final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return (email ?? phone ?? '?').substring(0, 1).toUpperCase();
    return (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
  }

  /// Google and Apple own the email; DomEase can only change it for email
  /// and phone accounts.
  bool get canChangeEmail => method == SignInMethod.email || method == SignInMethod.phone;

  /// Only email accounts have a DomEase password.
  bool get hasPassword => method == SignInMethod.email;

  Session copyWith({String? name, String? email, String? phone}) => Session(
        userId: userId,
        token: token,
        method: method,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );
}
