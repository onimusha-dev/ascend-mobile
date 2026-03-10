import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingPageWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPageWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: cs.primary)
              .animate()
              .scale(duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 500.ms),
          const SizedBox(height: 32),
          Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .slideY(begin: 0.5, end: 0, duration: 400.ms, delay: 200.ms)
              .fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 16),
          Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .slideY(begin: 0.5, end: 0, duration: 400.ms, delay: 400.ms)
              .fadeIn(duration: 400.ms, delay: 400.ms),
        ],
      ),
    );
  }
}
