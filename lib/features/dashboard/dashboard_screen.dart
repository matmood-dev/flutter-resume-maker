import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resume_provider.dart';
import '../../providers/ai_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final resumeState = ref.watch(resumeProvider);
    final aiState = ref.watch(aiProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (resumeState.resumes.isEmpty && !resumeState.isLoading) {
        ref.read(resumeProvider.notifier).loadResumes();
      }
      if (aiState.aiCredits == 10 && !aiState.isGenerating) {
        ref.read(aiProvider.notifier).loadCredits();
      }
    });

    final firstName = user?.fullName.split(' ').first ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, firstName),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('Quick Stats', onTap: () {}),
                const Gap(12),
                _buildQuickStats(resumeState.resumes.length, aiState.aiCredits),
                const Gap(24),
                _buildSectionHeader('Quick Actions', onTap: () {}),
                const Gap(12),
                _buildQuickActions(context),
                const Gap(24),
                _buildSectionHeader('Recent Resumes', onTap: () {}),
                const Gap(12),
                _buildRecentResumes(context, resumeState.resumes),
                const Gap(24),
                _buildSectionHeader('AI Tools', onTap: () {}),
                const Gap(12),
                _buildAITools(context),
                const Gap(32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName) {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white70),
                    ),
                    const Gap(4),
                    Text(
                      '${_getGreeting()}, $firstName',
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const Gap(20),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search resumes, templates...',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: Colors.white54),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white54,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        TextButton(
          onPressed: onTap,
          child: Text(
            'See All',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(int totalResumes, int aiCredits) {
    final stats = [
      _StatItem(
        icon: Icons.description_outlined,
        count: '$totalResumes',
        label: 'Total Resumes',
        color: AppColors.primary,
      ),
      _StatItem(
        icon: Icons.auto_awesome,
        count: '$aiCredits',
        label: 'AI Credits',
        color: const Color(0xFF9C7CFF),
      ),
      _StatItem(
        icon: Icons.download_outlined,
        count: '0',
        label: 'Downloads',
        color: AppColors.success,
      ),
      _StatItem(
        icon: Icons.send_outlined,
        count: '0',
        label: 'Applications',
        color: AppColors.warning,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: stat.color.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon, color: stat.color, size: 20),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat.count,
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(
                      stat.label,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.add_circle_outline,
        label: 'Create\nResume',
        color: AppColors.primary,
      ),
      _ActionItem(
        icon: Icons.auto_awesome_outlined,
        label: 'Improve\nResume',
        color: const Color(0xFF9C7CFF),
      ),
      _ActionItem(
        icon: Icons.mail_outline,
        label: 'Cover\nLetter',
        color: AppColors.success,
      ),
      _ActionItem(
        icon: Icons.quiz_outlined,
        label: 'Interview\nQuestions',
        color: AppColors.warning,
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, _) => const Gap(12),
        itemBuilder: (context, index) {
          final action = actions[index];
          return Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: action.color.withAlpha(51),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, color: action.color, size: 28),
                const Gap(8),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textWhite, height: 1.2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentResumes(
      BuildContext context, List<dynamic> resumes) {
    final recentResumes = resumes.length > 5 ? resumes.sublist(0, 5) : resumes;

    if (recentResumes.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No resumes yet. Create your first resume!',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recentResumes.length,
        separatorBuilder: (_, _) => const Gap(12),
        itemBuilder: (context, index) {
          final resume = recentResumes[index];
          return Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        resume.title,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (resume.atsScore != null)
                      _buildAtsBadge(resume.atsScore!.toInt()),
                  ],
                ),
                const Gap(8),
                Text(
                  resume.templateId ?? 'No template',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textGrey,
                    ),
                    const Gap(4),
                    Expanded(
                      child: Text(
                        'Edited ${_formatDate(resume.updatedAt)}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAtsBadge(int score) {
    Color color;
    if (score >= 85) {
      color = AppColors.success;
    } else if (score >= 70) {
      color = AppColors.warning;
    } else {
      color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'ATS $score',
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  Widget _buildAITools(BuildContext context) {
    final tools = [
      _ToolItem(
        icon: Icons.auto_awesome,
        title: 'AI Resume Generator',
        description: 'Generate professional resumes with AI',
      ),
      _ToolItem(
        icon: Icons.fact_check_outlined,
        title: 'ATS Scanner',
        description: 'Check ATS compatibility score',
      ),
      _ToolItem(
        icon: Icons.work_outline,
        title: 'Job Analyzer',
        description: 'Analyze job descriptions',
      ),
      _ToolItem(
        icon: Icons.dashboard_outlined,
        title: 'Portfolio Builder',
        description: 'Build online portfolio',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tool.icon, color: AppColors.primary, size: 24),
              const Gap(8),
              Text(
                tool.title,
                style: AppTextStyles.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(4),
              Text(
                tool.description,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textGrey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem {
  final IconData icon;
  final String count;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _ToolItem {
  final IconData icon;
  final String title;
  final String description;

  const _ToolItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
