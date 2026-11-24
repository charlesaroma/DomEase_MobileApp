// ─── Content Repository (demo) ────────────────────────────────────
import 'package:domease/data/model/content_json.dart';
import 'package:domease/data/repositories/content/content_repository.dart';
import 'package:domease/data/services/bundled_legal.dart';
import 'package:domease/data/services/demo_assets.dart';
import 'package:domease/domain/models/content.dart';
import 'package:domease/domain/models/currency.dart';
import 'package:domease/domain/models/legal.dart';

class ContentRepositoryLocal implements ContentRepository {
  @override
  Future<List<Nudge>> nudges() async => [
        for (final j in await loadDemoList('nudges'))
          if (j['active'] != false) nudgeFromJson(j),
      ];

  @override
  Future<AppSettings> settings() async => settingsFromJson(await loadDemoMap('settings'));

  @override
  Future<RateTable> rates() async => ratesFromJson(await loadDemoMap('currencies'));

  @override
  Future<LegalDoc> legal(LegalDocId id) async => legalFromJson(await loadBundledLegal(id.name));

  /// The demo has nowhere to send it; a short pause shows the sending state.
  @override
  Future<void> sendReport({required String topic, required String message, required String appVersion}) =>
      Future<void>.delayed(const Duration(milliseconds: 600));
}
