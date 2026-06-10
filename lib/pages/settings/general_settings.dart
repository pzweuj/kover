import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/riverpod/providers/settings/general_settings.dart';
import 'package:kover/riverpod/providers/theme.dart' hide Theme;
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/settings/boolean_option.dart';
import 'package:kover/widgets/settings/choice_option.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GeneralSettings extends ConsumerWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final generalSettings = ref.watch(generalSettingsProvider);
    final l10n = context.l10n;

    return Card(
      margin: LayoutConstants.mediumEdgeInsets,
      child: Padding(
        padding: LayoutConstants.mediumEdgeInsets,
        child: Async(
          asyncValue: theme,
          data: (theme) => Column(
            mainAxisSize: .min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: LayoutConstants.largePadding,
            children: [
              Text(
                l10n.general,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ChoiceOption(
                title: l10n.themeMode,
                icon: LucideIcons.palette,
                options: [
                  ChoiceOptionEntry(
                    value: ThemeMode.system,
                    label: l10n.system,
                    icon: LucideIcons.sunMoon,
                  ),
                  ChoiceOptionEntry(
                    value: ThemeMode.light,
                    label: l10n.light,
                    icon: LucideIcons.sun,
                  ),
                  ChoiceOptionEntry(
                    value: ThemeMode.dark,
                    label: l10n.dark,
                    icon: LucideIcons.moon,
                  ),
                ],
                value: theme.mode,
                onChanged: (newValue) async {
                  await ref.read(themeProvider.notifier).setMode(newValue);
                },
              ),
              BooleanOption(
                title: l10n.outlinedTheme,
                icon: LucideIcons.squareDashed,
                value: theme.outlined,
                onChanged: (value) =>
                    ref.read(themeProvider.notifier).setOutlined(value),
              ),
              Async(
                asyncValue: generalSettings,
                data: (generalSettings) => Column(
                  spacing: LayoutConstants.largePadding,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChoiceOption<String>(
                      title: l10n.language,
                      icon: LucideIcons.languages,
                      options: [
                        ChoiceOptionEntry(
                          value: 'en',
                          label: l10n.english,
                        ),
                        ChoiceOptionEntry(
                          value: 'zh',
                          label: l10n.chinese,
                        ),
                      ],
                      value: generalSettings.localeCode,
                      onChanged: (value) => ref
                          .read(generalSettingsProvider.notifier)
                          .setLocaleCode(value),
                    ),
                    BooleanOption(
                      title: l10n.anonymousDiagnostics,
                      icon: KoverIcons.analytics,
                      description: l10n.anonymousDiagnosticsDescription,
                      value: generalSettings.sendDiagnostics,
                      onChanged: (value) => ref
                          .read(generalSettingsProvider.notifier)
                          .setSendDiagnostics(value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
