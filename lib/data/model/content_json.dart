// ─── Content JSON ─────────────────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/domain/models/content.dart';
import 'package:domease/domain/models/currency.dart';
import 'package:domease/domain/models/house_help.dart';
import 'package:domease/domain/models/legal.dart';
import 'package:domease/domain/models/zone.dart';
import 'package:domease/domain/models/zone_presets.dart';

Nudge nudgeFromJson(Json j) => Nudge(id: j['id'] as String, text: j['text'] as String);

/// `ads` is a list of placements on newer servers, a map of screen → on in older seed data.
AppSettings settingsFromJson(Json j, {List<Json>? placements, List<Json>? sponsored}) {
  final premium = (j['premium'] as Json?) ?? const {};
  final ads = j['ads'];
  final maintenance = j['maintenance'] as Json?;
  return AppSettings(
    monthlyPrice: toIntOrNull(premium['monthlyPrice']),
    yearlyPrice: toIntOrNull(premium['yearlyPrice']),
    ads: ads is Json ? {for (final e in ads.entries) e.key: e.value == true} : const {},
    placements: [for (final p in placements ?? (ads is List ? ads.cast<Json>() : const <Json>[])) placementFromJson(p)],
    sponsored: [for (final d in sponsored ?? ((j['sponsored'] as List?)?.cast<Json>() ?? const <Json>[])) dealFromJson(d)],
    dietaryDisclaimer: (j['dietaryDisclaimer'] as String?) ?? 'This is general guidance, not medical advice.',
    supportEmail: (j['supportEmail'] as String?) ?? 'hello@domease.app',
    trialDays: toIntOrNull(j['trialDays']) ?? 0,
    minAppVersion: (j['minAppVersion'] as String?) ?? '1.0.0',
    maintenance: maintenance?['on'] == true ? (maintenance?['message'] as String? ?? '') : null,
  );
}

AdPlacement placementFromJson(Json j) => AdPlacement(
      id: j['id'] as String,
      enabled: j['enabled'] == true,
      native: j['format'] == 'native',
      admobAndroid: (j['admobAndroid'] as String?) ?? '',
      admobIos: (j['admobIos'] as String?) ?? '',
    );

SponsoredDeal dealFromJson(Json j) => SponsoredDeal(
      id: j['id'] as String,
      brand: (j['brand'] as String?) ?? '',
      product: (j['product'] as String?) ?? '',
      headline: (j['headline'] as String?) ?? '',
      link: (j['link'] as String?) ?? '',
      imageUrl: ((j['image'] as Json?)?['url']) as String?,
      screens: strings(j['screens']),
      matchItems: strings(j['matchItems']),
    );

/// Running now: switched on and between its dates.
bool dealIsLive(Json j, DateTime now) =>
    j['active'] == true &&
    (DateTime.tryParse('${j['startsAt']}')?.isBefore(now) ?? false) &&
    (DateTime.tryParse('${j['endsAt']}')?.isAfter(now) ?? false);

Faq faqFromJson(Json j) => Faq(question: j['question'] as String, answer: j['answer'] as String);

PremiumFeatureInfo premiumFeatureFromJson(Json j) => PremiumFeatureInfo(
      id: j['id'] as String,
      title: j['title'] as String,
      description: (j['description'] as String?) ?? '',
      comingSoon: j['comingSoon'] == true,
    );

Occasion occasionFromJson(Json j) => Occasion(id: j['id'] as String, name: j['name'] as String);

ZonePreset zonePresetFromJson(Json j) => ZonePreset(
      j['name'] as String,
      [for (final t in (j['tasks'] as List?) ?? const []) ((t as Json)['label'] as String, byName(Frequency.values, t['frequency'], Frequency.weekly))],
      [
        for (final c in (j['consumables'] as List?) ?? const [])
          ((c as Json)['name'] as String, byName(Frequency.values, c['replenishmentCycle'], Frequency.monthly)),
      ],
    );

/// Active and in the admin's order.
List<Json> sortedActive(List<Json> rows, {String flag = 'active'}) =>
    [...rows.where((r) => r[flag] != false)]..sort((a, b) => (toIntOrNull(a['sortOrder']) ?? 0).compareTo(toIntOrNull(b['sortOrder']) ?? 0));

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
