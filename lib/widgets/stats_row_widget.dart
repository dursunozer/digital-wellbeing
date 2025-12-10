import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Widget showing Unlocks and Notifications count in a row
class StatsRowWidget extends StatelessWidget {
  final int unlockCount;
  final int notificationCount;

  const StatsRowWidget({
    super.key,
    required this.unlockCount,
    required this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.lock_open,
              value: unlockCount > 0 ? unlockCount.toString() : '-',
              label: l10n.unlocks,
              isDarkMode: isDarkMode,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.notifications_none,
              value: notificationCount > 0 ? notificationCount.toString() : '-',
              label: l10n.notifications,
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDarkMode;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            if (value != '-') ...[
              const SizedBox(width: 4),
              Icon(
                Icons.info_outline,
                size: 16,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
