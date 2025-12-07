import '../l10n/app_localizations.dart';

/// Utility class for formatting durations into human-readable strings
class DurationFormatter {
  /// Format duration into a human-readable string with localized units
  static String format(Duration duration, AppLocalizations l10n) {
    if (duration.inSeconds < 1) {
      return '0${l10n.timeUnitSeconds}';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];

    if (hours > 0) {
      parts.add('$hours${l10n.timeUnitHours}');
    }

    if (minutes > 0) {
      parts.add('$minutes${l10n.timeUnitMinutes}');
    }

    // Only show seconds if total duration is less than 1 minute
    if (hours == 0 && minutes == 0 && seconds > 0) {
      parts.add('$seconds${l10n.timeUnitSeconds}');
    }

    return parts.join(' ');
  }

  /// Format duration in a more verbose way (e.g., "2 hours 15 minutes")
  static String formatVerbose(Duration duration, AppLocalizations l10n) {
    if (duration.inSeconds < 1) {
      return '0 ${l10n.timeUnitSeconds}';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];

    if (hours > 0) {
      parts.add('$hours ${l10n.timeUnitHours}');
    }

    if (minutes > 0) {
      parts.add('$minutes ${l10n.timeUnitMinutes}');
    }

    if (hours == 0 && minutes == 0 && seconds > 0) {
      parts.add('$seconds ${l10n.timeUnitSeconds}');
    }

    return parts.join(' ');
  }

  /// Format duration for chart labels (compact format)
  static String formatCompact(Duration duration, AppLocalizations l10n) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours${l10n.timeUnitHours} $minutes${l10n.timeUnitMinutes}';
    } else if (minutes > 0) {
      return '$minutes${l10n.timeUnitMinutes}';
    } else {
      return '${duration.inSeconds}${l10n.timeUnitSeconds}';
    }
  }
}
