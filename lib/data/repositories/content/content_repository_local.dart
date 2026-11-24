// ─── Content Repository (demo) ────────────────────────────────────
import 'package:domease/data/model/content_json.dart';
import 'package:domease/data/repositories/content/content_repository.dart';
import 'package:domease/data/services/bundled_legal.dart';
import 'package:domease/data/services/demo_assets.dart';
import 'package:domease/domain/models/content.dart';
import 'package:domease/domain/models/currency.dart';
import 'package:domease/domain/models/legal.dart';
import 'package:domease/domain/models/zone_presets.dart';

class ContentRepositoryLocal implements ContentRepository {
  @override
  Future<List<Nudge>> nudges() async => [
        for (final j in await loadDemoList('nudges'))
          if (j['active'] != false) nudgeFromJson(j),
      ];

  @override
  Future<AppSettings> settings() async {
    final now = DateTime.now();
    return settingsFromJson(
      await loadDemoMap('settings'),
      placements: await loadDemoList('ad_placements'),
      sponsored: [for (final d in await loadDemoList('sponsored')) if (dealIsLive(d, now)) d],
    );
  }

  @override
  Future<RateTable> rates() async => ratesFromJson(await loadDemoMap('currencies'));

  @override
  Future<LegalDoc> legal(LegalDocId id) async => legalFromJson(await loadBundledLegal(id.name));

  /// The demo has nowhere to send it; a short pause shows the sending state.
  @override
  Future<void> sendReport({required String topic, required String message, required String appVersion}) =>
      Future<void>.delayed(const Duration(milliseconds: 600));

  @override
  Future<List<Faq>> faqs() async => [for (final j in sortedActive(await loadDemoList('faqs'))) faqFromJson(j)];

  @override
  Future<List<PremiumFeatureInfo>> premiumFeatures() async =>
      [for (final j in sortedActive(await loadDemoList('premium_features'), flag: 'shown')) premiumFeatureFromJson(j)];

  @override
  Future<List<Occasion>> occasions() async => [for (final j in sortedActive(await loadDemoList('occasions'))) occasionFromJson(j)];

  @override
  Future<List<ZonePreset>> zonePresets() async => [for (final j in sortedActive(await loadDemoList('zone_presets'))) zonePresetFromJson(j)];

  @override
  Future<void> adEvent(String sponsoredId, String type) async {}
}
