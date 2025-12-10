import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../models/app_usage_info.dart';
import '../utils/duration_formatter.dart';
import '../l10n/app_localizations.dart';

/// Circular usage chart widget similar to Android Digital Wellbeing
class CircularUsageChart extends StatelessWidget {
  final List<AppUsageInfo> apps;
  final Duration totalScreenTime;

  const CircularUsageChart({
    super.key,
    required this.apps,
    required this.totalScreenTime,
  });

  // Colors for different apps
  static const List<Color> _appColors = [
    Color(0xFF4285F4), // Google Blue
    Color(0xFF34A853), // Google Green
    Color(0xFFFBBC05), // Google Yellow
    Color(0xFFEA4335), // Google Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF9800), // Orange
    Color(0xFF607D8B), // Blue Grey
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (apps.isEmpty) {
      return _buildEmptyState(l10n, isDarkMode);
    }

    // Get top 5 apps for the chart
    final topApps = apps.take(5).toList();
    final otherDuration = apps.skip(5).fold(
      Duration.zero,
      (sum, app) => sum + app.usageDuration,
    );

    return SizedBox(
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pie chart
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: PieChart(
              PieChartData(
                sections: _buildSections(topApps, otherDuration, isDarkMode),
                centerSpaceRadius: 70,
                sectionsSpace: 2,
                startDegreeOffset: -90,
              ),
            ),
          ),
          
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.today,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DurationFormatter.format(totalScreenTime, l10n),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          
          // App labels around the chart
          ..._buildAppLabels(topApps, otherDuration, isDarkMode, l10n),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDarkMode) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDataAvailable,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    List<AppUsageInfo> topApps,
    Duration otherDuration,
    bool isDarkMode,
  ) {
    final total = totalScreenTime.inSeconds.toDouble();
    if (total == 0) return [];

    final List<PieChartSectionData> sections = [];

    for (int i = 0; i < topApps.length; i++) {
      final app = topApps[i];
      
      sections.add(
        PieChartSectionData(
          color: _appColors[i % _appColors.length],
          value: app.usageDuration.inSeconds.toDouble(),
          title: '',
          radius: 35,
          showTitle: false,
        ),
      );
    }

    // Add "Other" section if there are more apps
    if (otherDuration.inSeconds > 0) {
      sections.add(
        PieChartSectionData(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
          value: otherDuration.inSeconds.toDouble(),
          title: '',
          radius: 35,
          showTitle: false,
        ),
      );
    }

    return sections;
  }

  List<Widget> _buildAppLabels(
    List<AppUsageInfo> topApps,
    Duration otherDuration,
    bool isDarkMode,
    AppLocalizations l10n,
  ) {
    final total = totalScreenTime.inSeconds.toDouble();
    if (total == 0) return [];

    final List<Widget> labels = [];
    final centerX = 160.0; // Half of width
    final centerY = 160.0; // Half of height
    final labelRadius = 130.0;

    double currentAngle = -90; // Start from top

    for (int i = 0; i < topApps.length && i < 4; i++) {
      final app = topApps[i];
      final sweepAngle = (app.usageDuration.inSeconds / total) * 360;
      final midAngle = currentAngle + (sweepAngle / 2);
      
      final radians = midAngle * (math.pi / 180);
      final labelX = centerX + labelRadius * math.cos(radians);
      final labelY = centerY + labelRadius * math.sin(radians);

      labels.add(
        Positioned(
          left: labelX - 40,
          top: labelY - 10,
          child: SizedBox(
            width: 80,
            child: Text(
              _truncateAppName(app.appName),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _appColors[i % _appColors.length],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      currentAngle += sweepAngle;
    }

    return labels;
  }

  String _truncateAppName(String name) {
    if (name.length > 12) {
      return '${name.substring(0, 10)}...';
    }
    return name;
  }
}
