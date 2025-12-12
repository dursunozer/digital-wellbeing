import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pie chart with center text
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pie chart
              PieChart(
                PieChartData(
                  sections: _buildSections(topApps, otherDuration, isDarkMode),
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Legend list below chart
        _buildLegend(topApps, otherDuration, isDarkMode, l10n),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDarkMode) {
    return SizedBox(
      height: 280,
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

  Widget _buildLegend(
    List<AppUsageInfo> topApps,
    Duration otherDuration,
    bool isDarkMode,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Top apps legend
          ...topApps.asMap().entries.map((entry) {
            final index = entry.key;
            final app = entry.value;
            return _LegendItem(
              color: _appColors[index % _appColors.length],
              appName: app.appName,
              duration: DurationFormatter.format(app.usageDuration, l10n),
              isDarkMode: isDarkMode,
            );
          }),
          // Other apps if exists
          if (otherDuration.inSeconds > 0)
            _LegendItem(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
              appName: 'Other',
              duration: DurationFormatter.format(otherDuration, l10n),
              isDarkMode: isDarkMode,
            ),
        ],
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
          radius: 30,
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
          radius: 30,
          showTitle: false,
        ),
      );
    }

    return sections;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String appName;
  final String duration;
  final bool isDarkMode;

  const _LegendItem({
    required this.color,
    required this.appName,
    required this.duration,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              appName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            duration,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
