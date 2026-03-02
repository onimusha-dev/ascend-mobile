import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Dummy data representing messages from the server
    final serverMessages = [
      {
        'title': 'Welcome to Ascend!',
        'message':
            'We are glad to have you on board. Start organizing your life today by creating your first task.',
        'time': 'Just now',
        'isRead': false,
        'icon': Icons.celebration_rounded,
        'color': Colors.amber,
      },
      {
        'title': 'System maintenance',
        'message':
            'The server will be down for scheduled maintenance on Sunday at 2:00 AM UTC. Please sync your tasks beforehand.',
        'time': '2 hours ago',
        'isRead': true,
        'icon': Icons.build_circle_rounded,
        'color': cs.primary,
      },
      {
        'title': 'New Feature Alert',
        'message':
            'You can now categorize your tasks with custom icons and colors! Go to settings to try it out.',
        'time': '1 day ago',
        'isRead': true,
        'icon': Icons.new_releases_rounded,
        'color': Colors.green,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inbox',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.primary,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.done_all_rounded, color: cs.primary),
            tooltip: 'Mark all as read',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: serverMessages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forward_to_inbox_rounded,
                    size: 80,
                    color: cs.primary.withAlpha(50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When the server sends you updates,\nthey will appear here.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 120,
              ),
              itemCount: serverMessages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final msg = serverMessages[index];
                final isRead = msg['isRead'] as bool;
                final iconColor = msg['color'] as Color;

                return Material(
                  color: isRead
                      ? cs.surfaceContainerHighest.withAlpha(40)
                      : cs.surfaceContainerHighest.withAlpha(120),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isRead
                                  ? cs.surfaceContainerHighest
                                  : iconColor.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              msg['icon'] as IconData,
                              color: isRead ? cs.onSurfaceVariant : iconColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        msg['title'] as String,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.w900,
                                              color: cs.onSurface,
                                              letterSpacing: -0.3,
                                            ),
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(
                                          top: 6,
                                          left: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cs.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  msg['message'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isRead
                                        ? cs.onSurfaceVariant.withAlpha(180)
                                        : cs.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  msg['time'] as String,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
