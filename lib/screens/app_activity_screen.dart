import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
import '../models/app_usage_info.dart';
import '../providers/usage_providers.dart';
import '../utils/duration_formatter.dart';
import '../utils/app_themes.dart';

/// Screen showing detailed app activity similar to Android Digital Wellbeing
class AppActivityScreen extends ConsumerWidget {
  const AppActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final usageAsync = ref.watch(appUsageProvider);
    final totalScreenTime = ref.watch(totalScreenTimeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appActivityTitle),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode 
                  ? AppThemes.darkGradient 
                  : AppThemes.lightGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.grey.shade900, Colors.black]
                : [Colors.grey.shade50, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: usageAsync.when(
          data: (apps) => _buildContent(context, l10n, isDarkMode, apps, totalScreenTime),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    bool isDarkMode,
    List<AppUsageInfo> apps,
    Duration totalScreenTime,
  ) {
    return CustomScrollView(
      slivers: [
        // Weekly chart section
        SliverToBoxAdapter(
          child: _buildWeeklyChart(context, l10n, isDarkMode, totalScreenTime),
        ),

        // Usage by app header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.usageByApp,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),

        // App list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final app = apps[index];
              return _AppUsageItem(
                app: app,
                totalTime: totalScreenTime,
                isDarkMode: isDarkMode,
                l10n: l10n,
              );
            },
            childCount: apps.length,
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(
    BuildContext context,
    AppLocalizations l10n,
    bool isDarkMode,
    Duration totalScreenTime,
  ) {
    // Simulated weekly data (in a real app, this would come from database)
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIndex = DateTime.now().weekday - 1;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dailyAverage,
                    style: TextStyle(
                      fontSize: 14,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.thisWeek,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: totalScreenTime.inMinutes.toDouble() * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < weekDays.length) {
                          final isToday = index == todayIndex;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              weekDays[index],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday
                                    ? (isDarkMode ? Colors.blue[300] : Colors.blue[700])
                                    : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  // Simulated data - in real app this would come from database
                  final isToday = index == todayIndex;
                  final value = isToday
                      ? totalScreenTime.inMinutes.toDouble()
                      : (totalScreenTime.inMinutes * (0.5 + (index * 0.1))).toDouble();
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: isToday
                            ? (isDarkMode ? Colors.blue[400] : Colors.blue[600])
                            : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                        width: 24,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppUsageItem extends StatelessWidget {
  final AppUsageInfo app;
  final Duration totalTime;
  final bool isDarkMode;
  final AppLocalizations l10n;

  const _AppUsageItem({
    required this.app,
    required this.totalTime,
    required this.isDarkMode,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalTime.inSeconds > 0
        ? (app.usageDuration.inSeconds / totalTime.inSeconds)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // App icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: app.appIcon != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      app.appIcon!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.android,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                  ),
          ),
          const SizedBox(width: 12),
          
          // App info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.appName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 4,
                    backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? Colors.blue[400]! : Colors.blue[600]!,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Usage time
          Text(
            DurationFormatter.format(app.usageDuration, l10n),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
