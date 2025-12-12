import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/feature_settings.dart';

/// Feature menu item callback
typedef FeatureMenuCallback = void Function();

/// Widget showing feature menu items like App Timers, Bedtime Mode, etc.
class FeatureMenuWidget extends StatelessWidget {
  final int appTimersCount;
  final BedtimeSettings bedtimeSettings;
  final FocusSettings focusSettings;
  final bool screenTimeRemindersEnabled;
  
  final FeatureMenuCallback onAppTimersTap;
  final FeatureMenuCallback onBedtimeModeTap;
  final FeatureMenuCallback onFocusTap;
  final FeatureMenuCallback onScreenTimeRemindersTap;

  const FeatureMenuWidget({
    super.key,
    required this.appTimersCount,
    required this.bedtimeSettings,
    required this.focusSettings,
    required this.screenTimeRemindersEnabled,
    required this.onAppTimersTap,
    required this.onBedtimeModeTap,
    required this.onFocusTap,
    required this.onScreenTimeRemindersTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ways to disconnect section
        _SectionHeader(
          title: l10n.waysToDisconnect,
          isDarkMode: isDarkMode,
        ),
        _MenuCard(
          isDarkMode: isDarkMode,
          children: [
            _MenuItem(
              icon: Icons.timer_outlined,
              title: l10n.appTimers,
              subtitle: appTimersCount > 0
                  ? l10n.appTimersSubtitleCount(appTimersCount)
                  : l10n.appTimersSubtitle,
              onTap: onAppTimersTap,
              isDarkMode: isDarkMode,
            ),
            _MenuDivider(isDarkMode: isDarkMode),
            _MenuItem(
              icon: Icons.bedtime_outlined,
              title: l10n.bedtimeMode,
              subtitle: bedtimeSettings.isEnabled
                  ? l10n.bedtimeModeSchedule(
                      bedtimeSettings.startTimeString,
                      bedtimeSettings.endTimeString,
                    )
                  : l10n.bedtimeModeOff,
              onTap: onBedtimeModeTap,
              isDarkMode: isDarkMode,
            ),
            _MenuDivider(isDarkMode: isDarkMode),
            _MenuItem(
              icon: Icons.center_focus_strong_outlined,
              title: l10n.focus,
              subtitle: focusSettings.isEnabled
                  ? l10n.focusActive
                  : l10n.focusTapToSetUp,
              onTap: onFocusTap,
              isDarkMode: isDarkMode,
            ),
            _MenuDivider(isDarkMode: isDarkMode),
            _MenuItem(
              icon: Icons.access_alarm,
              title: l10n.screenTimeReminders,
              subtitle: screenTimeRemindersEnabled
                  ? l10n.screenTimeRemindersOn
                  : l10n.screenTimeRemindersOff,
              onTap: onScreenTimeRemindersTap,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDarkMode;

  const _SectionHeader({
    required this.title,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDarkMode;

  const _MenuCard({
    required this.children,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  final bool isDarkMode;

  const _MenuDivider({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 1,
      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
    );
  }
}
