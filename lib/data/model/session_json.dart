// ─── Session JSON ─────────────────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/domain/models/session.dart';

/// From the API's `{ token, user: { id, name, email, phone } }`.
Session sessionFromApi(Json j, SignInMethod method) {
  final user = (j['user'] as Json?) ?? const {};
  return Session(
    userId: '${user['id']}',
    token: j['token'] as String,
    method: method,
    name: user['name'] as String?,
    email: user['email'] as String?,
    phone: user['phone'] as String?,
  );
}

Session sessionFromJson(Json j) => Session(
      userId: j['userId'] as String,
      token: j['token'] as String,
      method: byName(SignInMethod.values, j['method'], SignInMethod.email),
      name: j['name'] as String?,
      email: j['email'] as String?,
      phone: j['phone'] as String?,
    );

Json sessionToJson(Session s) => {
      'userId': s.userId,
      'token': s.token,
      'method': s.method.name,
      'name': s.name,
      'email': s.email,
      'phone': s.phone,
    };
