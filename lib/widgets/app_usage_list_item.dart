import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/app_usage_info.dart';
import '../utils/duration_formatter.dart';

class AppUsageListItem extends StatelessWidget {
  final AppUsageInfo app;
  final double maxUsage;

  const AppUsageListItem({
    super.key,
    required this.app,
    required this.maxUsage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final progress = maxUsage > 0 
        ? (app.usageDuration.inMinutes / maxUsage).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // App Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(app.appName),
              borderRadius: BorderRadius.circular(12),
            ),
            child: app.appIcon != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      app.appIcon!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // If image fails to load, show fallback
                        return _buildFallbackIcon(app.appName);
                      },
                    ),
                  )
                : _buildFallbackIcon(app.appName),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.appName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DurationFormatter.format(app.usageDuration, l10n),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress),
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

  Color _getProgressColor(double progress) {
    if (progress > 0.7) {
      return Colors.red.shade400;
    } else if (progress > 0.4) {
      return Colors.orange.shade400;
    } else {
      return Colors.green.shade400;
    }
  }

  Widget _buildFallbackIcon(String appName) {
    final firstLetter = appName.isNotEmpty ? appName[0].toUpperCase() : '?';
    
    return Center(
      child: Text(
        firstLetter,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(String appName) {
    final colors = [
      const Color(0xFF2196F3), 
      const Color(0xFF00BCD4), 
      const Color(0xFFFF9800), 
      const Color(0xFF4CAF50), 
      const Color(0xFF9C27B0), 
      const Color(0xFFE91E63), 
      const Color(0xFF00BCD4), 
      const Color(0xFFFFC107), 
    ];
    
    final hash = appName.hashCode.abs();
    return colors[hash % colors.length];
  }
}
