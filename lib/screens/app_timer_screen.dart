import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/app_usage_info.dart';
import '../models/feature_settings.dart';
import '../providers/usage_providers.dart';
import '../services/usage_database.dart';
import '../utils/app_themes.dart';
import '../utils/duration_formatter.dart';

/// Screen for managing app timers with usage tracking
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
    final usedMinutes = app.usageDuration.inMinutes;
    final limitMinutes = timer.dailyLimit.inMinutes;
    
    // Calculate progress (0.0 to 1.0+)
    final progress = hasTimer && limitMinutes > 0 
        ? usedMinutes / limitMinutes 
        : 0.0;
    final isOverLimit = progress >= 1.0;
    final remainingMinutes = hasTimer ? (limitMinutes - usedMinutes) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOverLimit 
            ? Border.all(color: Colors.red, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App info row
            Row(
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
                          child: Image.memory(app.appIcon!, fit: BoxFit.cover),
                        )
                      : Icon(
                          Icons.android,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                        ),
                ),
                const SizedBox(width: 12),
                
                // App name and usage info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.appName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DurationFormatter.format(app.usageDuration, l10n),
                        style: TextStyle(
                          fontSize: 13,
                          color: isOverLimit 
                              ? Colors.red[400]
                              : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Timer icon or set timer button
                InkWell(
                  onTap: () => _showTimerDialog(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasTimer
                          ? (isOverLimit 
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.blue.withValues(alpha: 0.1))
                          : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasTimer ? Icons.timer : Icons.timer_outlined,
                      size: 24,
                      color: hasTimer
                          ? (isOverLimit ? Colors.red : Colors.blue)
                          : (isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                    ),
                  ),
                ),
              ],
            ),
            
            // Progress bar (only if timer is set)
            if (hasTimer) ...[
              const SizedBox(height: 12),
              
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverLimit ? Colors.red : Colors.blue,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Time info row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.limit}: ${timer.dailyLimit.inMinutes} ${l10n.minutes}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  if (isOverLimit)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l10n.limitExceeded,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[600],
                        ),
                      ),
                    )
                  else
                    Text(
                      '$remainingMinutes ${l10n.minutes} ${l10n.remaining}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.green[400] : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
            
            // No limit text
            if (!hasTimer) ...[
              const SizedBox(height: 4),
              Text(
                l10n.noLimit,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(l10n.setTimer),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App icon and name
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: app.appIcon != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(app.appIcon!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.android, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          app.appName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Time selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (selectedMinutes > 5) {
                            setDialogState(() => selectedMinutes -= 5);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline, size: 32),
                        color: Colors.blue,
                      ),
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Text(
                              '$selectedMinutes',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.minutes,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (selectedMinutes < 480) {
                            setDialogState(() => selectedMinutes += 5);
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 32),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Quick select buttons
                  Wrap(
                    spacing: 8,
                    children: [15, 30, 60, 120].map((mins) {
                      return ActionChip(
                        label: Text(mins >= 60 ? '${mins ~/ 60}h' : '${mins}m'),
                        onPressed: () => setDialogState(() => selectedMinutes = mins),
                        backgroundColor: selectedMinutes == mins 
                            ? Colors.blue[100] 
                            : null,
                      );
                    }).toList(),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
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
