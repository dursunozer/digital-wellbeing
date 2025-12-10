import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/app_usage_info.dart';
import '../models/feature_settings.dart';
import '../providers/usage_providers.dart';
import '../services/usage_database.dart';
import '../utils/app_themes.dart';

/// Screen for managing app timers
class AppTimerScreen extends ConsumerStatefulWidget {
  const AppTimerScreen({super.key});

  @override
  ConsumerState<AppTimerScreen> createState() => _AppTimerScreenState();
}

class _AppTimerScreenState extends ConsumerState<AppTimerScreen> {
  final UsageDatabase _database = UsageDatabase();
  List<AppTimer> _timers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimers();
  }

  Future<void> _loadTimers() async {
    final timers = await _database.getAppTimers();
    setState(() {
      _timers = timers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appsAsync = ref.watch(appUsageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTimers),
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
            : appsAsync.when(
                data: (apps) => _buildAppList(context, l10n, isDarkMode, apps),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
      ),
    );
  }

  Widget _buildAppList(
    BuildContext context,
    AppLocalizations l10n,
    bool isDarkMode,
    List<AppUsageInfo> apps,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final timer = _timers.firstWhere(
          (t) => t.packageName == app.packageName,
          orElse: () => AppTimer(
            packageName: app.packageName,
            appName: app.appName,
            dailyLimit: Duration.zero,
            isEnabled: false,
          ),
        );

        return _AppTimerItem(
          app: app,
          timer: timer,
          isDarkMode: isDarkMode,
          l10n: l10n,
          onTimerChanged: (newTimer) async {
            if (newTimer.dailyLimit.inMinutes > 0) {
              await _database.saveAppTimer(newTimer);
            } else {
              await _database.deleteAppTimer(app.packageName);
            }
            await _loadTimers();
          },
        );
      },
    );
  }
}

class _AppTimerItem extends StatelessWidget {
  final AppUsageInfo app;
  final AppTimer timer;
  final bool isDarkMode;
  final AppLocalizations l10n;
  final Function(AppTimer) onTimerChanged;

  const _AppTimerItem({
    required this.app,
    required this.timer,
    required this.isDarkMode,
    required this.l10n,
    required this.onTimerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasTimer = timer.dailyLimit.inMinutes > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: app.appIcon != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(app.appIcon!, fit: BoxFit.cover),
                )
              : Icon(
                  Icons.android,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                ),
        ),
        title: Text(
          app.appName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: hasTimer
            ? Text(
                '${timer.dailyLimit.inMinutes} ${l10n.minutes}',
                style: TextStyle(
                  color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                ),
              )
            : Text(
                l10n.noLimit,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
        trailing: Icon(
          hasTimer ? Icons.timer : Icons.timer_outlined,
          color: hasTimer
              ? (isDarkMode ? Colors.blue[300] : Colors.blue[700])
              : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
        ),
        onTap: () => _showTimerDialog(context),
      ),
    );
  }

  void _showTimerDialog(BuildContext context) {
    int selectedMinutes = timer.dailyLimit.inMinutes;
    if (selectedMinutes == 0) selectedMinutes = 30;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.setTimer),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(app.appName),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (selectedMinutes > 5) {
                            setDialogState(() => selectedMinutes -= 5);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          '$selectedMinutes',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (selectedMinutes < 480) {
                            setDialogState(() => selectedMinutes += 5);
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  Text(l10n.minutes),
                ],
              ),
              actions: [
                if (timer.dailyLimit.inMinutes > 0)
                  TextButton(
                    onPressed: () {
                      onTimerChanged(timer.copyWith(dailyLimit: Duration.zero));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.timerRemoved)),
                      );
                    },
                    child: Text(
                      l10n.delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    onTimerChanged(timer.copyWith(
                      dailyLimit: Duration(minutes: selectedMinutes),
                      isEnabled: true,
                    ));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.timerSet)),
                    );
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
