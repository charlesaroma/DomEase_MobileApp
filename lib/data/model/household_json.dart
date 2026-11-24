// ─── Household JSON ───────────────────────────────────────────────
// The API sends snake_case enum values (single_parent, house_help).
import 'package:domease/data/model/json.dart';
import 'package:domease/domain/models/household.dart';

const _types = {'bachelor': HouseholdType.bachelor, 'couple': HouseholdType.couple, 'family': HouseholdType.family, 'single_parent': HouseholdType.singleParent};
const _roles = {'owner': MemberRole.owner, 'member': MemberRole.member, 'house_help': MemberRole.houseHelp};

String _key<T>(Map<String, T> map, T value) => map.entries.firstWhere((e) => e.value == value).key;

Household householdFromJson(Json j) => Household(
      id: j['id'] as String,
      name: (j['name'] as String?) ?? 'Our home',
      type: _types[j['type']] ?? HouseholdType.family,
      size: toIntOrNull(j['size']) ?? 1,
      currency: (j['currency'] as String?) ?? 'UGX',
      tier: j['tier'] == 'premium' ? Tier.premium : Tier.free,
      members: [
        for (final m in (j['members'] as List?) ?? const [])
          HouseholdMember(
            id: (m as Json)['id'] as String,
            name: m['name'] as String,
            role: _roles[m['role']] ?? MemberRole.member,
            ageGroup: byName(AgeGroup.values, m['ageGroup'], AgeGroup.adults),
            allergies: strings(m['allergies']),
          ),
      ],
      goals: strings(j['goals']),
      mealFocus: strings(j['mealFocus']),
      diet: (j['diet'] as String?) ?? 'none',
    );

Json householdToJson(Household h) => {
      'id': h.id,
      'name': h.name,
      'type': _key(_types, h.type),
      'size': h.size,
      'currency': h.currency,
      'tier': h.tier.name,
      'members': [
        for (final m in h.members)
          {'id': m.id, 'name': m.name, 'role': _key(_roles, m.role), 'ageGroup': m.ageGroup.name, 'allergies': m.allergies},
      ],
      'goals': h.goals,
      'mealFocus': h.mealFocus,
      'diet': h.diet,
    };
