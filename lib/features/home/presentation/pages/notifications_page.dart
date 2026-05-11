import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.notifications_active_outlined,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMockTitle(index),
                          style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getMockBody(index),
                          style:
                              theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${index + 1}h ago',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppColors.textTertiaryLight),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (index * 100).ms)
              .slideX(begin: 0.05, end: 0);
        },
      ),
    );
  }

  String _getMockTitle(int index) {
    const titles = [
      'EMI Payment Due',
      'Loan Approved',
      'Saving Goal Reached',
      'New Member Added',
      'System Update',
    ];
    return titles[index % titles.length];
  }

  String _getMockBody(int index) {
    const bodies = [
      'Member Sayan has an EMI due today for Loan #L-4582.',
      'Your disbursement request for Member Rahul has been approved.',
      'Congratulations! You have reached 50% of your Education goal.',
      'A new retail member has joined your group.',
      'Financial year closing updates are now available.',
    ];
    return bodies[index % bodies.length];
  }
}
