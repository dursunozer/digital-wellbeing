import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
import '../models/app_usage_info.dart';
import '../models/daily_usage.dart';
import '../providers/usage_providers.dart';
import '../utils/duration_formatter.dart';
import '../utils/app_themes.dart';
import '../services/usage_database.dart';

/// Screen showing detailed app activity with selectable days
class AppActivityScreen extends ConsumerStatefulWidget {
  const AppActivityScreen({super.key});

  @override
  ConsumerState<AppActivityScreen> createState() => _AppActivityScreenState();
}

class _AppActivityScreenState extends ConsumerState<AppActivityScreen> {
  int _selectedDayIndex = 6; // Today (last item in week array)
  List<DailyUsage> _weeklyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    final db = UsageDatabase();
    final history = await db.getUsageHistory(7);
    
    // Create a map of date string to daily usage
    final dataMap = <String, DailyUsage>{};
    for (final usage in history) {
      final dateStr = _formatDate(usage.date);
      dataMap[dateStr] = usage;
    }
    
    // Build 7 days array (from 6 days ago to today)
    final now = DateTime.now();
    final weekData = <DailyUsage>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      
      if (dataMap.containsKey(dateStr)) {
        weekData.add(dataMap[dateStr]!);
      } else {
        // No data for this day - create empty entry
        weekData.add(DailyUsage(
          date: date,
          totalScreenTime: Duration.zero,
          unlockCount: 0,
          notificationCount: 0,
          apps: [],
        ));
      }
    }
    
    setState(() {
      _weeklyData = weekData;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final todayApps = ref.watch(appUsageProvider);
    final todayTotalTime = ref.watch(totalScreenTimeProvider);

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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : todayApps.when(
                data: (apps) => _buildContent(context, l10n, isDarkMode, apps, todayTotalTime),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    bool isDarkMode,
    List<AppUsageInfo> todayApps,
    Duration todayTotalTime,
  ) {
    // Get selected day's data
    final selectedData = _weeklyData.isNotEmpty && _selectedDayIndex < _weeklyData.length
        ? _weeklyData[_selectedDayIndex]
        : null;
    
    // For today (index 6), use real-time data
    final isToday = _selectedDayIndex == 6;
    final displayApps = isToday ? todayApps : (selectedData?.apps ?? []);
    final displayTotalTime = isToday ? todayTotalTime : (selectedData?.totalScreenTime ?? Duration.zero);
    
    // Update weekly data with today's current data
    if (isToday && _weeklyData.isNotEmpty) {
      _weeklyData[6] = DailyUsage(
        date: DateTime.now(),
        totalScreenTime: todayTotalTime,
        unlockCount: 0,
        notificationCount: 0,
        apps: todayApps,
      );
    }
    
    // Calculate daily average
    final totalMinutes = _weeklyData.fold<int>(
      0, (sum, day) => sum + day.totalScreenTime.inMinutes
    );
    final daysWithData = _weeklyData.where((d) => d.totalScreenTime.inMinutes > 0).length;
    final averageMinutes = daysWithData > 0 ? totalMinutes ~/ daysWithData : 0;

    return CustomScrollView(
      slivers: [
        // Weekly chart section
        SliverToBoxAdapter(
          child: _buildWeeklyChart(context, l10n, isDarkMode, Duration(minutes: averageMinutes)),
        ),

        // Usage by app header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.usageByApp,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  DurationFormatter.format(displayTotalTime, l10n),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ),

        // App list
        displayApps.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 48,
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
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final app = displayApps[index];
                    return _AppUsageItem(
                      app: app,
                      totalTime: displayTotalTime,
                      isDarkMode: isDarkMode,
                      l10n: l10n,
                    );
                  },
                  childCount: displayApps.length,
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
    Duration averageTime,
  ) {
    final weekDays = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];

    // Get max value for chart scaling
    final maxMinutes = _weeklyData.isEmpty 
        ? 60.0 
        : _weeklyData.map((d) => d.totalScreenTime.inMinutes).reduce((a, b) => a > b ? a : b).toDouble();
    final chartMax = maxMinutes > 0 ? maxMinutes * 1.2 : 60.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
                    DurationFormatter.format(averageTime, l10n),
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
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartMax,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (event.isInterestedForInteractions &&
                        response != null &&
                        response.spot != null) {
                      setState(() {
                        _selectedDayIndex = response.spot!.touchedBarGroupIndex;
                      });
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < 7 && _weeklyData.isNotEmpty) {
                          final date = _weeklyData[index].date;
                          final dayOfWeek = date.weekday - 1; // 0-6
                          final isSelected = index == _selectedDayIndex;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDayIndex = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    weekDays[dayOfWeek],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected
                                          ? (isDarkMode ? Colors.blue[300] : Colors.blue[700])
                                          : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 36,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  final isSelected = index == _selectedDayIndex;
                  final value = _weeklyData.isNotEmpty && index < _weeklyData.length
                      ? _weeklyData[index].totalScreenTime.inMinutes.toDouble()
                      : 0.0;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value > 0 ? value : 1, // Min height for visibility
                        color: isSelected
                            ? (isDarkMode ? Colors.blue[400] : Colors.blue[600])
                            : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                        width: 28,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
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
