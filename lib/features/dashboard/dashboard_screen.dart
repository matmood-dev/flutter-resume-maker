import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
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
            child: _buildHeader(context, firstName, user?.profileImage),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildQuickActions(context),
                const Gap(28),
                _buildStatsRow(resumeState.resumes.length, aiState.aiCredits),
                const Gap(28),
                _buildSectionHeader(
                  'Recent Resumes',
                  onTap: () => context.go('/home/resumes'),
                ),
                const Gap(12),
                _buildRecentResumes(context, resumeState.resumes),
                const Gap(28),
                _buildSectionHeader('AI Tools', onTap: () {}),
                const Gap(12),
                _buildAITools(context),
                const Gap(20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName, String? profileImage) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
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
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white60),
                    ),
                    const Gap(4),
                    Text(
                      firstName,
                      style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/home/profile'),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha(77), width: 1.5),
                  ),
                  child: profileImage != null && profileImage.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        )
                      : const Icon(Icons.person_outline, color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
          const Gap(20),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search coming soon'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Gap(14),
                  Icon(Icons.search, color: Colors.white54, size: 20),
                  const Gap(10),
                  Text(
                    'Search resumes, templates...',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                  ),
                ],
              ),
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

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.add_circle_outline,
        label: 'Create\nResume',
        color: AppColors.primary,
        onTap: () => context.push('/resume/create'),
      ),
      _ActionItem(
        icon: Icons.auto_awesome_outlined,
        label: 'AI\nAssistant',
        color: const Color(0xFF9C7CFF),
        onTap: () => context.go('/home/ai'),
      ),
      _ActionItem(
        icon: Icons.mail_outline,
        label: 'Cover\nLetter',
        color: AppColors.success,
        onTap: () => context.push('/cover-letter/create'),
      ),
      _ActionItem(
        icon: Icons.document_scanner_outlined,
        label: 'ATS\nScanner',
        color: AppColors.warning,
        onTap: () => context.push('/scanner'),
      ),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (a, b) => const Gap(12),
        itemBuilder: (context, index) {
          final action = actions[index];
          return GestureDetector(
            onTap: action.onTap,
            child: Container(
              width: 84,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: action.color.withAlpha(38),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(action.icon, color: action.color, size: 20),
                  ),
                  const Gap(6),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textWhite,
                      height: 1.1,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(int totalResumes, int aiCredits) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.description_outlined,
            count: '$totalResumes',
            label: 'Resumes',
            color: AppColors.primary,
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.auto_awesome,
            count: '$aiCredits',
            label: 'AI Credits',
            color: const Color(0xFF9C7CFF),
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.picture_as_pdf_outlined,
            count: '0',
            label: 'PDFs',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Gap(6),
          Text(count, style: AppTextStyles.titleMedium),
          const Gap(2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'See All',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentResumes(BuildContext context, List<dynamic> resumes) {
    if (resumes.isEmpty) {
      return GestureDetector(
        onTap: () => context.push('/resume/create'),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withAlpha(51)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, color: AppColors.primary, size: 32),
                const Gap(8),
                Text(
                  'Create your first resume',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final recentResumes = resumes.length > 4 ? resumes.sublist(0, 4) : resumes;

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recentResumes.length,
        separatorBuilder: (a, b) => const Gap(12),
        itemBuilder: (context, index) {
          final resume = recentResumes[index];
          return GestureDetector(
            onTap: () => context.push('/resume/create', extra: resume),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(38),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 18),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          resume.title,
                          style: AppTextStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (resume.summary.isNotEmpty)
                    Text(
                      resume.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textGrey,
                        height: 1.3,
                      ),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      if (resume.atsScore != null) ...[
                        _buildAtsBadge(resume.atsScore!.toInt()),
                        const Gap(8),
                      ],
                      Icon(Icons.access_time, size: 12, color: AppColors.textGrey),
                      const Gap(4),
                      Text(
                        _formatDate(resume.updatedAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textGrey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'ATS $score',
        style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 9),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  Widget _buildAITools(BuildContext context) {
    final tools = [
      _ToolItem(
        icon: Icons.auto_awesome,
        title: 'AI Resume Builder',
        description: 'Generate with AI',
        color: AppColors.primary,
      ),
      _ToolItem(
        icon: Icons.edit_note,
        title: 'Smart Editor',
        description: 'Improve your text',
        color: const Color(0xFF9C7CFF),
      ),
      _ToolItem(
        icon: Icons.fact_check_outlined,
        title: 'ATS Scanner',
        description: 'Check compatibility',
        color: AppColors.success,
      ),
      _ToolItem(
        icon: Icons.work_outline,
        title: 'Job Analyzer',
        description: 'Analyze descriptions',
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
        childAspectRatio: 1.8,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coming soon'),
                backgroundColor: AppColors.warning,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tool.color.withAlpha(38)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tool.color.withAlpha(38),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tool.icon, color: tool.color, size: 20),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tool.title,
                        style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(2),
                      Text(
                        tool.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textGrey,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _ToolItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _ToolItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
