import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FocusModeScreen extends StatelessWidget {
  const FocusModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Text(
              'Focus Session',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 8),
            Text(
              'Deep work, no distractions.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            _buildTimer(context),
            const Spacer(),
            _buildActionButtons(context),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary.withAlpha(50), width: 2),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withAlpha(20),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '25:00',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.primary,
                letterSpacing: -2,
              ),
            ),
            Text(
              'MINUTES',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.primary.withAlpha(150),
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .shimmer(duration: 3.seconds, color: cs.primaryContainer.withAlpha(100));
  }

  Widget _buildActionButtons(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleButton(Icons.refresh_rounded, cs.surfaceContainerHighest, cs.onSurfaceVariant),
        const SizedBox(width: 24),
        _buildCircleButton(Icons.play_arrow_rounded, cs.primary, Colors.white, size: 80, iconSize: 40),
        const SizedBox(width: 24),
        _buildCircleButton(Icons.settings_rounded, cs.surfaceContainerHighest, cs.onSurfaceVariant),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, Color bg, Color fg, {double size = 60, double iconSize = 24}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bg.withAlpha(40),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: fg, size: iconSize),
    );
  }
}
