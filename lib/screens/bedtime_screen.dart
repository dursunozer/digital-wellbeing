import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/feature_settings.dart';
import '../services/usage_database.dart';
import '../utils/app_themes.dart';

/// Screen for managing bedtime mode settings
class BedtimeScreen extends ConsumerStatefulWidget {
  const BedtimeScreen({super.key});

  @override
  ConsumerState<BedtimeScreen> createState() => _BedtimeScreenState();
}

class _BedtimeScreenState extends ConsumerState<BedtimeScreen> {
  final UsageDatabase _database = UsageDatabase();
  BedtimeSettings _settings = BedtimeSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _database.getBedtimeSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _database.saveBedtimeSettings(_settings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bedtimeSettingsTitle),
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
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, bool isDarkMode) {
    final dayNames = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Enable/Disable toggle
        _buildCard(
          isDarkMode,
          child: SwitchListTile(
            title: Text(
              l10n.bedtimeMode,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              _settings.isEnabled ? l10n.on : l10n.off,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            value: _settings.isEnabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(isEnabled: value);
              });
              _saveSettings();
            },
          ),
        ),

        const SizedBox(height: 16),

        // Time settings
        _buildCard(
          isDarkMode,
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.bedtime,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
                title: Text(
                  l10n.bedtimeStart,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Text(
                  _settings.startTimeString,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                  ),
                ),
                onTap: () => _selectTime(context, true),
              ),
              Divider(
                height: 1,
                indent: 56,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              ListTile(
                leading: Icon(
                  Icons.wb_sunny_outlined,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
                title: Text(
                  l10n.bedtimeEnd,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Text(
                  _settings.endTimeString,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                  ),
                ),
                onTap: () => _selectTime(context, false),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Active days
        _buildCard(
          isDarkMode,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bedtimeActiveDays,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final dayNumber = index + 1;
                    final isActive = _settings.activeDays.contains(dayNumber);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          final newDays = List<int>.from(_settings.activeDays);
                          if (isActive) {
                            newDays.remove(dayNumber);
                          } else {
                            newDays.add(dayNumber);
                          }
                          _settings = _settings.copyWith(activeDays: newDays);
                        });
                        _saveSettings();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? (isDarkMode ? Colors.blue[700] : Colors.blue[600])
                              : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            dayNames[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isActive
                                  ? Colors.white
                                  : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bedtime options
        _buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.bedtimeOptions,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(
                  l10n.grayscale,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                value: _settings.grayscale,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(grayscale: value);
                  });
                  _saveSettings();
                },
              ),
              Divider(
                height: 1,
                indent: 16,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              SwitchListTile(
                title: Text(
                  l10n.doNotDisturb,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                value: _settings.doNotDisturb,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(doNotDisturb: value);
                  });
                  _saveSettings();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isDarkMode, {required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final currentTime = isStart ? _settings.startTime : _settings.endTime;
    final time = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          _settings = _settings.copyWith(startTime: time);
        } else {
          _settings = _settings.copyWith(endTime: time);
        }
      });
      _saveSettings();
    }
  }
}
