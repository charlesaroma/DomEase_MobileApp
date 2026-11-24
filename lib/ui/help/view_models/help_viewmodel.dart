// ─── Help View Model ──────────────────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/ui/core/view_models/app_info_viewmodel.dart';

/// Sends a problem or an idea, with the app version, to the team.
final sendReportProvider = Provider<Future<void> Function(String topic, String message)>((ref) => (topic, message) async {
      final version = await ref.read(appVersionProvider.future);
      await ref.read(contentRepositoryProvider).sendReport(topic: topic, message: message, appVersion: version);
    });
