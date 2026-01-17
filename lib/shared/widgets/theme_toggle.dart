// lib/shared/widgets/theme_toggle.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  final bool showLabel;

  const ThemeToggle({super.key, this.showLabel = false});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Icon(
            Icons.light_mode,
            color: isDark ? Colors.grey[400] : theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Light',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : theme.colorScheme.primary,
              fontSize: 14,
            ),
          ),
        ],
        Switch(
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme(value);
          },
          activeColor: theme.colorScheme.primary,
          inactiveThumbColor: Colors.grey[600],
          inactiveTrackColor: Colors.grey[800],
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            'Dark',
            style: TextStyle(
              color: isDark ? theme.colorScheme.primary : Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.dark_mode,
            color: isDark ? theme.colorScheme.primary : Colors.grey[400],
            size: 18,
          ),
        ],
      ],
    );
  }
}

// Simple icon button version for app bars
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return IconButton(
      icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        themeProvider.toggleTheme(!themeProvider.isDarkMode);
      },
      tooltip: 'Toggle theme',
    );
  }
}
