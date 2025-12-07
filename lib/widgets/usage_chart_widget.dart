import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/app_usage_info.dart';
import '../utils/duration_formatter.dart';

class UsageChartWidget extends StatefulWidget {
  final List<AppUsageInfo> apps;

  const UsageChartWidget({
    super.key,
    required this.apps,
  });

  @override
  State<UsageChartWidget> createState() => _UsageChartWidgetState();
}

class _UsageChartWidgetState extends State<UsageChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.apps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noDataAvailable,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Use seconds for more accurate calculation (avoids 0 when usage < 1 minute)
    final totalSeconds = widget.apps.fold<double>(
      0,
      (sum, app) => sum + app.usageDuration.inSeconds,
    );

    final totalDuration = widget.apps.fold<Duration>(
      Duration.zero,
      (sum, app) => sum + app.usageDuration,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 280,
        child: Stack(
          children: [
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 65,
                sections: _getSections(totalSeconds, isDark, l10n),
              ),
            ),
            Center(
              child: Container(
                width: 110,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DurationFormatter.formatCompact(totalDuration, l10n),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections(double totalSeconds, bool isDark, AppLocalizations l10n) {
    final colors = [
      const Color(0xFF2196F3), 
      const Color(0xFF00BCD4), 
      const Color(0xFF4CAF50), 
      const Color(0xFFFF9800), 
      const Color(0xFFE91E63), 
    ];

    return widget.apps.asMap().entries.map((entry) {
      final index = entry.key;
      final app = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 62.0 : 52.0;
      
      // Use seconds for percentage calculation
      final percentage = totalSeconds > 0
          ? (app.usageDuration.inSeconds / totalSeconds) * 100
          : 0.0;

      // Create badge with app name and percentage
      final badgeWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: colors[index % colors.length],
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              app.appName.length > 8
                  ? '${app.appName.substring(0, 7)}..'
                  : app.appName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      );

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: app.usageDuration.inSeconds.toDouble(), // Use seconds for accurate display
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black26, blurRadius: 2),
          ],
        ),
        badgeWidget: badgeWidget,
        badgePositionPercentageOffset: 1.4,
      );
    }).toList();
  }
}
