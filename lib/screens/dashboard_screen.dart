import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/usage_providers.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_themes.dart';
import '../widgets/permission_request_widget.dart';
import '../widgets/circular_usage_chart.dart';
import '../widgets/stats_row_widget.dart';
import '../widgets/feature_menu_widget.dart';
import '../models/feature_settings.dart';
import '../screens/app_activity_screen.dart';
import '../screens/app_timer_screen.dart';
import '../screens/bedtime_screen.dart';
import '../screens/focus_screen.dart';
import '../screens/screen_time_reminders_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes to foreground
      ref.invalidate(appUsageProvider);
      ref.invalidate(appTimersProvider);
      ref.invalidate(bedtimeSettingsProvider);
      ref.invalidate(focusSettingsProvider);
      ref.invalidate(screenTimeRemindersProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final permissionAsync = ref.watch(permissionStatusProvider);
    final usageAsync = ref.watch(appUsageProvider);
    final totalScreenTime = ref.watch(totalScreenTimeProvider);
    final top5Apps = ref.watch(top5AppsProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final flagEmoji = ref.watch(localeProvider.select((locale) => 
        locale.languageCode == 'en' ? '🇬🇧' : '🇹🇷'));

    // Watch feature settings
    final appTimersAsync = ref.watch(appTimersProvider);
    final bedtimeAsync = ref.watch(bedtimeSettingsProvider);
    final focusAsync = ref.watch(focusSettingsProvider);
    final remindersAsync = ref.watch(screenTimeRemindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
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
        actions: [
          IconButton(
            icon: Text(
              flagEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
            tooltip: 'Change Language',
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreMenu(context, ref, l10n),
            tooltip: 'More',
          ),
        ],
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
        child: permissionAsync.when(
          data: (hasPermission) {
            if (!hasPermission) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const PermissionRequestWidget(),
                    const SizedBox(height: 20),
                    _buildInfoSection(l10n, isDarkMode),
                  ],
                ),
              );
            }

            return usageAsync.when(
              data: (apps) {
                if (apps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_android,
                          size: 80,
                          color: isDarkMode 
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noDataAvailable,
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.startUsingApps,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.grey.shade500
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Get feature settings with defaults
                final appTimersCount = appTimersAsync.when(
                  data: (timers) => timers.length,
                  loading: () => 0,
                  error: (_, __) => 0,
                );
                final bedtimeSettings = bedtimeAsync.when(
                  data: (settings) => settings,
                  loading: () => BedtimeSettings(),
                  error: (_, __) => BedtimeSettings(),
                );
                final focusSettings = focusAsync.when(
                  data: (settings) => settings,
                  loading: () => FocusSettings(),
                  error: (_, __) => FocusSettings(),
                );
                final remindersEnabled = remindersAsync.when(
                  data: (reminders) => reminders.any((r) => r.isEnabled),
                  loading: () => false,
                  error: (_, __) => false,
                );

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(appUsageProvider);
                    ref.invalidate(appTimersProvider);
                    ref.invalidate(bedtimeSettingsProvider);
                    ref.invalidate(focusSettingsProvider);
                    ref.invalidate(screenTimeRemindersProvider);
                    await ref.read(appUsageProvider.future);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Circular chart section
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CircularUsageChart(
                            apps: top5Apps,
                            totalScreenTime: totalScreenTime,
                          ),
                        ),

                        // Stats row (Unlocks and Notifications)
                        const StatsRowWidget(
                          unlockCount: 0, // Will be implemented with Android API
                          notificationCount: 0, // Will be implemented with NotificationListenerService
                        ),

                        const SizedBox(height: 16),

                        // View app activity details link
                        _buildActivityLink(context, l10n, isDarkMode),

                        const SizedBox(height: 16),

                        // Feature menu
                        FeatureMenuWidget(
                          appTimersCount: appTimersCount,
                          bedtimeSettings: bedtimeSettings,
                          focusSettings: focusSettings,
                          screenTimeRemindersEnabled: remindersEnabled,
                          onAppTimersTap: () => _navigateToAppTimers(context),
                          onBedtimeModeTap: () => _navigateToBedtime(context),
                          onFocusTap: () => _navigateToFocus(context),
                          onScreenTimeRemindersTap: () => _navigateToReminders(context),
                          onManageNotificationsTap: () => _openNotificationSettings(),
                          onHeadsUpTap: () => _showHeadsUpInfo(context, l10n),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      l10n.loadingData,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorLoadingData,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.invalidate(appUsageProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error checking permission: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityLink(BuildContext context, AppLocalizations l10n, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          Icons.bar_chart,
          color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
        ),
        title: Text(
          l10n.viewAppActivityDetails,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppActivityScreen()),
        ),
      ),
    );
  }

  void _navigateToAppTimers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppTimerScreen()),
    ).then((_) => ref.invalidate(appTimersProvider));
  }

  void _navigateToBedtime(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BedtimeScreen()),
    ).then((_) => ref.invalidate(bedtimeSettingsProvider));
  }

  void _navigateToFocus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FocusScreen()),
    ).then((_) => ref.invalidate(focusSettingsProvider));
  }

  void _navigateToReminders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScreenTimeRemindersScreen()),
    ).then((_) => ref.invalidate(screenTimeRemindersProvider));
  }

  void _openNotificationSettings() {
    // Open Android notification settings
    // This would require platform-specific code, for now just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening notification settings...')),
    );
  }

  void _showHeadsUpInfo(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.headsUp),
        content: const Text(
          'Heads Up helps you stay aware of your surroundings while walking by reminding you to look up from your phone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: Text(l10n.resetUsage),
              onTap: () {
                Navigator.pop(context);
                _showResetDialog(context, ref, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(AppLocalizations l10n, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whyPermission,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey.shade200 : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            Icons.analytics,
            l10n.trackUsage,
            l10n.trackUsageDesc,
            isDarkMode,
          ),
          _buildInfoItem(
            Icons.insights,
            l10n.gainInsights,
            l10n.gainInsightsDesc,
            isDarkMode,
          ),
          _buildInfoItem(
            Icons.trending_down,
            l10n.reduceScreenTime,
            l10n.reduceScreenTimeDesc,
            isDarkMode,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.blue.shade900.withOpacity(0.3)
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.privacy_tip,
                  color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.privacyNote,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.orange.shade900.withOpacity(0.3)
                  : Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.orange.shade300 : Colors.teal.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey.shade200 : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetConfirmTitle),
        content: Text(l10n.resetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        final prefsService = ref.read(preferencesServiceProvider);
        final usageService = ref.read(usageServiceProvider);
        
        try {
          // Get RAW usage data (without baseline subtraction) to save as baseline
          final usageInfoList = await usageService.fetchRawUsageData();
          
          // Create baseline map
          final baseline = <String, int>{};
          for (final app in usageInfoList) {
            baseline[app.packageName] = app.usageDuration.inSeconds;
          }
          
          // Save baseline
          await prefsService.setResetBaseline(baseline);
          
          // Set reset timestamp
          await prefsService.setResetTimestamp(DateTime.now());
          
          // Invalidate provider
          ref.invalidate(appUsageProvider);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.resetInProgress),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          // Error during reset - silently handled
        }
      }
    });
  }
}
