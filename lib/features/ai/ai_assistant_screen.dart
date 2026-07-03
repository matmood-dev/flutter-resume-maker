import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Gap(32),
                _buildComingSoonCard(),
                const Gap(32),
                _buildFeaturesSection(),
                const Gap(32),
                _buildNotifySection(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Assistant', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
          const Gap(8),
          Text(
            'Your intelligent career companion',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(51)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withAlpha(51),
                  AppColors.accent.withAlpha(51),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const Gap(20),
          Text(
            'Coming Soon',
            style: AppTextStyles.headlineMedium,
          ),
          const Gap(8),
          Text(
            'We\'re building something amazing for you. Our AI assistant will help you craft perfect resumes, write cover letters, and prepare for interviews.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      _FeatureItem(
        icon: Icons.auto_awesome,
        title: 'AI Resume Builder',
        description: 'Generate professional resumes tailored to your target job',
        color: AppColors.primary,
      ),
      _FeatureItem(
        icon: Icons.edit_note,
        title: 'Smart Text Improvement',
        description: 'Enhance your writing with AI-powered suggestions',
        color: const Color(0xFF9C7CFF),
      ),
      _FeatureItem(
        icon: Icons.mail_outline,
        title: 'Cover Letter Generator',
        description: 'Create personalized cover letters in seconds',
        color: AppColors.success,
      ),
      _FeatureItem(
        icon: Icons.psychology_outlined,
        title: 'Interview Coach',
        description: 'Practice with AI-generated interview questions',
        color: AppColors.warning,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What\'s Coming', style: AppTextStyles.titleLarge),
        const Gap(16),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: feature.color.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(feature.icon, color: feature.color, size: 24),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feature.title, style: AppTextStyles.titleSmall),
                      const Gap(4),
                      Text(
                        feature.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textGrey,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildNotifySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: AppColors.primary,
            size: 32,
          ),
          const Gap(12),
          Text(
            'Get Notified',
            style: AppTextStyles.titleMedium,
          ),
          const Gap(8),
          Text(
            'We\'ll let you know when AI Assistant is ready.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
          ),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You\'ll be notified when we launch!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Notify Me'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
