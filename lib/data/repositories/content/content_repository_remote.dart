// ─── Content Repository (API) ─────────────────────────────────────
import 'package:domease/data/model/content_json.dart';
import 'package:domease/data/model/json.dart';
import 'package:domease/data/repositories/content/content_repository.dart';
import 'package:domease/data/services/api/api_client.dart';
import 'package:domease/data/services/bundled_legal.dart';
import 'package:domease/domain/models/content.dart';
import 'package:domease/domain/models/content_fallbacks.dart';
import 'package:domease/domain/models/currency.dart';
import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/legal.dart';
import 'package:domease/domain/models/zone_presets.dart';
import 'package:domease/domain/models/zone_presets.dart' as builtin;

class ContentRepositoryRemote implements ContentRepository {
  ContentRepositoryRemote(this._api);

  final ApiClient _api;

  @override
  Future<List<Nudge>> nudges() async => [for (final j in await _api.get('/nudges') as List) nudgeFromJson(j as Json)];

  @override
  Future<AppSettings> settings() async => settingsFromJson(await _api.get('/settings/app') as Json);

  @override
  Future<RateTable> rates() async => ratesFromJson(await _api.get('/currencies') as Json);

  /// The live version when online; the copy in the app otherwise, so the
  /// Terms and Privacy Policy can always be read.
  @override
  Future<LegalDoc> legal(LegalDocId id) async {
    try {
      return legalFromJson(await _api.get('/legal/${id.name}') as Json);
    } on Failure {
      return legalFromJson(await loadBundledLegal(id.name));
    }
  }

  @override
  Future<void> sendReport({required String topic, required String message, required String appVersion}) async {
    await _api.post('/support/reports', {'topic': topic, 'message': message, 'appVersion': appVersion});
  }

  /// A list from the server, or [fallback] (the copy in the app) when offline.
  Future<List<T>> _list<T>(String path, T Function(Json) parse, List<T> fallback) async {
    try {
      return [for (final j in await _api.get(path) as List) parse(j as Json)];
    } on Failure {
      return fallback;
    }
  }

  @override
  Future<List<Faq>> faqs() => _list('/faqs', faqFromJson, fallbackFaqs);

  @override
  Future<List<PremiumFeatureInfo>> premiumFeatures() => _list('/premium-features', premiumFeatureFromJson, fallbackPremiumFeatures);

  @override
  Future<List<Occasion>> occasions() => _list('/occasions', occasionFromJson, fallbackOccasions);

  @override
  Future<List<ZonePreset>> zonePresets() => _list('/zone-presets', zonePresetFromJson, builtin.zonePresets);

  @override
  Future<void> adEvent(String sponsoredId, String type) async {
    try {
      await _api.post('/ads/events', {'sponsoredId': sponsoredId, 'type': type, 'platform': 'app'});
    } on Failure {
      // A lost count never interrupts the household.
    }
  }
}
