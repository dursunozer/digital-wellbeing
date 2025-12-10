import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/feature_settings.dart';
import '../services/usage_database.dart';
import '../utils/app_themes.dart';

/// Screen for managing screen time reminders
class ScreenTimeRemindersScreen extends ConsumerStatefulWidget {
  const ScreenTimeRemindersScreen({super.key});

  @override
  ConsumerState<ScreenTimeRemindersScreen> createState() =>
      _ScreenTimeRemindersScreenState();
}

class _ScreenTimeRemindersScreenState
    extends ConsumerState<ScreenTimeRemindersScreen> {
  final UsageDatabase _database = UsageDatabase();
  List<ScreenTimeReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await _database.getScreenTimeReminders();
    setState(() {
      _reminders = reminders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenTimeReminders),
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
            : _buildContent(context, l10n, isDarkMode),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReminderDialog(context, l10n, isDarkMode),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    bool isDarkMode,
  ) {
    if (_reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_alarm,
              size: 64,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.screenTimeRemindersOff,
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addReminder,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return _ReminderItem(
          reminder: reminder,
          isDarkMode: isDarkMode,
          l10n: l10n,
          onToggle: () async {
            final updated = reminder.copyWith(isEnabled: !reminder.isEnabled);
            await _database.saveScreenTimeReminder(updated);
            _loadReminders();
          },
          onDelete: () async {
            if (reminder.id != null) {
              await _database.deleteScreenTimeReminder(reminder.id!);
              _loadReminders();
            }
          },
          onEdit: () => _showReminderDialog(
            context,
            l10n,
            isDarkMode,
            existingReminder: reminder,
          ),
        );
      },
    );
  }

  void _showReminderDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDarkMode, {
    ScreenTimeReminder? existingReminder,
  }) {
    int selectedMinutes = existingReminder?.threshold.inMinutes ?? 60;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingReminder != null ? l10n.editReminder : l10n.addReminder,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.reminderThreshold),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (selectedMinutes > 15) {
                            setDialogState(() => selectedMinutes -= 15);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            Text(
                              selectedMinutes >= 60
                                  ? '${selectedMinutes ~/ 60}'
                                  : '$selectedMinutes',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              selectedMinutes >= 60 ? l10n.hours : l10n.minutes,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (selectedMinutes < 480) {
                            setDialogState(() => selectedMinutes += 15);
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final reminder = ScreenTimeReminder(
                      id: existingReminder?.id,
                      threshold: Duration(minutes: selectedMinutes),
                      isEnabled: true,
                    );
                    await _database.saveScreenTimeReminder(reminder);
                    Navigator.pop(context);
                    _loadReminders();
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

class _ReminderItem extends StatelessWidget {
  final ScreenTimeReminder reminder;
  final bool isDarkMode;
  final AppLocalizations l10n;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ReminderItem({
    required this.reminder,
    required this.isDarkMode,
    required this.l10n,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = reminder.threshold.inMinutes;
    final displayText = minutes >= 60
        ? '${minutes ~/ 60} ${l10n.hours}'
        : '$minutes ${l10n.minutes}';

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
            color: reminder.isEnabled
                ? (isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue[50])
                : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.access_alarm,
            color: reminder.isEnabled
                ? (isDarkMode ? Colors.blue[300] : Colors.blue[700])
                : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
          ),
        ),
        title: Text(
          displayText,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          reminder.isEnabled ? l10n.on : l10n.off,
          style: TextStyle(
            color: reminder.isEnabled
                ? (isDarkMode ? Colors.green[300] : Colors.green[700])
                : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: reminder.isEnabled,
              onChanged: (_) => onToggle(),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.editReminder),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
