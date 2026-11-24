// ─── Content JSON ─────────────────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/domain/models/content.dart';
import 'package:domease/domain/models/currency.dart';
import 'package:domease/domain/models/house_help.dart';
import 'package:domease/domain/models/legal.dart';

Nudge nudgeFromJson(Json j) => Nudge(id: j['id'] as String, text: j['text'] as String);

AppSettings settingsFromJson(Json j) {
  final premium = (j['premium'] as Json?) ?? const {};
  return AppSettings(
    monthlyPrice: toIntOrNull(premium['monthlyPrice']),
    yearlyPrice: toIntOrNull(premium['yearlyPrice']),
    ads: {for (final e in ((j['ads'] as Json?) ?? const {}).entries) e.key: e.value == true},
    dietaryDisclaimer: (j['dietaryDisclaimer'] as String?) ?? 'This is general guidance, not medical advice.',
    supportEmail: (j['supportEmail'] as String?) ?? 'hello@domease.app',
  );
}

LegalDoc legalFromJson(Json j) => LegalDoc(
      id: byName(LegalDocId.values, j['id'], LegalDocId.terms),
      title: j['title'] as String,
      updated: DateTime.tryParse('${j['updated']}') ?? DateTime(2026, 10, 30),
      summary: (j['summary'] as String?) ?? '',
      sections: [
        for (final s in (j['sections'] as List?) ?? const [])
          LegalSection(heading: (s as Json)['heading'] as String, paragraphs: strings(s['paragraphs'])),
      ],
    );

RateTable ratesFromJson(Json j) => RateTable(
      updatedAt: DateTime.tryParse('${j['updatedAt']}') ?? DateTime.now(),
      rates: [
        for (final r in (j['rates'] as List?) ?? const [])
          Currency(code: (r as Json)['code'] as String, name: r['name'] as String, perUsd: toDouble(r['perUsd'], 1)),
      ],
    );

VettingQuestion questionFromJson(Json j) => VettingQuestion(
      id: j['id'] as String,
      section: j['section'] as String,
      text: j['text'] as String,
      options: [
        for (final o in (j['options'] as List?) ?? const []) VettingOption(label: (o as Json)['label'] as String, weight: toIntOrNull(o['weight']) ?? 0),
      ],
    );

VettingResult resultFromJson(Json j) => VettingResult(
      percent: toIntOrNull(j['fitScore']) ?? 0,
      flags: strings(j['flaggedConcerns']),
      bySection: {for (final e in ((j['bySection'] as Json?) ?? const {}).entries) e.key: toIntOrNull(e.value) ?? 0},
    );

Guide guideFromJson(Json j) => Guide(
      id: j['id'] as String,
      title: j['title'] as String,
      summary: (j['summary'] as String?) ?? '',
      pages: toIntOrNull(j['pages']) ?? 1,
      fileUrl: (j['fileUrl'] as String?) ?? '',
    );
