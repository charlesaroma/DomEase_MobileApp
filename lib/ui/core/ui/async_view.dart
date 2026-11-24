// ─── Async View ───────────────────────────────────────────────────
// Every screen that waits on data shows the same loading and error states
// (docs/03-flutter-dos-and-donts.md: AsyncValue.when for every async screen).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/brand/animated_logo.dart';

class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.data, this.onRetry});

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => value.when(
        data: data,
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(AppSpace.huge), child: LogoLoader())),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_outlined, size: 36, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: AppSpace.md),
                Text('$e', textAlign: TextAlign.center, style: AppText.body.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                if (onRetry != null) ...[
                  const SizedBox(height: AppSpace.lg),
                  OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
                ],
              ],
            ),
          ),
        ),
      );
}
