import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/app_usage_info.dart';
import '../models/feature_settings.dart';
import '../providers/usage_providers.dart';
import '../services/usage_database.dart';
import '../utils/app_themes.dart';

/// Screen for managing focus mode settings
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  final UsageDatabase _database = UsageDatabase();
  FocusSettings _settings = FocusSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _database.getFocusSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _database.saveFocusSettings(_settings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appsAsync = ref.watch(appUsageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.focusModeTitle),
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
                data: (apps) => _buildContent(context, l10n, isDarkMode, apps),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
      ),
      floatingActionButton: _settings.blockedPackages.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _settings = _settings.copyWith(isEnabled: !_settings.isEnabled);
                });
                _saveSettings();
              },
              icon: Icon(_settings.isEnabled ? Icons.stop : Icons.play_arrow),
              label: Text(_settings.isEnabled ? l10n.endFocus : l10n.startFocus),
              backgroundColor: _settings.isEnabled ? Colors.red : Colors.green,
            )
          : null,
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    bool isDarkMode,
    List<AppUsageInfo> apps,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Focus status card
        if (_settings.isEnabled) _buildActiveCard(l10n, isDarkMode),

        // Select apps header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.selectAppsToBlock,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),

        // Apps list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              final isBlocked = _settings.blockedPackages.contains(app.packageName);

              return _AppBlockItem(
                app: app,
                isBlocked: isBlocked,
                isDarkMode: isDarkMode,
                onToggle: () {
                  setState(() {
                    final newBlocked = List<String>.from(_settings.blockedPackages);
                    if (isBlocked) {
                      newBlocked.remove(app.packageName);
                    } else {
                      newBlocked.add(app.packageName);
                    }
                    _settings = _settings.copyWith(blockedPackages: newBlocked);
                  });
                  _saveSettings();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCard(AppLocalizations l10n, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.center_focus_strong,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.focusActive,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_settings.blockedPackages.length} apps paused',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBlockItem extends StatelessWidget {
  final AppUsageInfo app;
  final bool isBlocked;
  final bool isDarkMode;
  final VoidCallback onToggle;

  const _AppBlockItem({
    required this.app,
    required this.isBlocked,
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isBlocked
            ? Border.all(
                color: isDarkMode ? Colors.blue[700]! : Colors.blue[400]!,
                width: 2,
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: app.appIcon != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
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
        trailing: Checkbox(
          value: isBlocked,
          onChanged: (_) => onToggle(),
          activeColor: isDarkMode ? Colors.blue[400] : Colors.blue[600],
        ),
        onTap: onToggle,
      ),
    );
  }
}
