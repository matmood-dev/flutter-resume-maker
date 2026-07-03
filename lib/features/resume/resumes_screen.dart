import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/resume_provider.dart';

enum _Filter { all, recent, favorites }

class ResumesScreen extends ConsumerStatefulWidget {
  const ResumesScreen({super.key});

  @override
  ConsumerState<ResumesScreen> createState() => _ResumesScreenState();
}

class _ResumesScreenState extends ConsumerState<ResumesScreen> {
  _Filter _selectedFilter = _Filter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(resumeProvider.notifier).loadResumes());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumeProvider);
    final resumes = _filterResumes(state.resumes);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(state.resumes.length),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: state.isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                : resumes.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState())
                    : _buildResumeGrid(resumes),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterResumes(List<dynamic> resumes) {
    switch (_selectedFilter) {
      case _Filter.all:
        return resumes;
      case _Filter.recent:
        final sorted = List.of(resumes)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return sorted.take(5).toList();
      case _Filter.favorites:
        return resumes.where((r) => r.atsScore != null && r.atsScore! >= 85).toList();
    }
  }

  Widget _buildHeader(int totalCount) {
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
                child: Text('My Resumes', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
              ),
              GestureDetector(
                onTap: () => context.push('/resume/create'),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            '$totalCount resume${totalCount == 1 ? '' : 's'} created',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          const Gap(16),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: _Filter.values.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(
              filter.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.background : Colors.white70,
              ),
            ),
            selected: isSelected,
            selectedColor: Colors.white,
            backgroundColor: Colors.white.withAlpha(25),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) => setState(() => _selectedFilter = filter),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResumeGrid(List resumes) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final resume = resumes[index];
          return _ResumeCard(
            resume: resume,
            onTap: () => context.push('/resume/create', extra: resume),
            onDelete: () => _confirmDelete(resume),
          );
        },
        childCount: resumes.length,
      ),
    );
  }

  void _confirmDelete(dynamic resume) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGrey.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: AppColors.error, size: 28),
            ),
            const Gap(16),
            Text('Delete Resume', style: AppTextStyles.titleMedium),
            const Gap(8),
            Text(
              'Are you sure you want to delete "${resume.title}"? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textWhite,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref.read(resumeProvider.notifier).deleteResume(resume.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const Gap(24),
            Text('No Resumes Yet', style: AppTextStyles.headlineMedium),
            const Gap(8),
            Text(
              'Create your first resume and land your dream job with AI-powered insights.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
            ),
            const Gap(24),
            ElevatedButton.icon(
              onPressed: () => context.push('/resume/create'),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final dynamic resume;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ResumeCard({
    required this.resume,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final score = resume.atsScore;
    final scoreColor = score == null
        ? AppColors.textGrey
        : score >= 85
            ? AppColors.success
            : score >= 70
                ? AppColors.warning
                : AppColors.error;

    final hasExperience = (resume.experience as List).isNotEmpty;
    final hasEducation = (resume.education as List).isNotEmpty;
    final skillCount = (resume.skills as List).length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(38),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
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
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.textGrey, size: 18),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit') onTap();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const Gap(8),
                          Text('Edit', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          const Gap(8),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            if (resume.summary.isNotEmpty)
              Text(
                resume.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, height: 1.4),
              ),
            const Spacer(),
            Row(
              children: [
                _buildStat(Icons.work_outline, '$hasExperience'),
                const Gap(8),
                _buildStat(Icons.school_outlined, '$hasEducation'),
                const Gap(8),
                _buildStat(Icons.psychology_outlined, '$skillCount'),
              ],
            ),
            const Gap(10),
            Row(
              children: [
                if (score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoreColor.withAlpha(38),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.analytics_outlined, size: 12, color: scoreColor),
                        const Gap(4),
                        Text(
                          'ATS ${score.round()}',
                          style: AppTextStyles.labelSmall.copyWith(color: scoreColor),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Icon(Icons.access_time, size: 11, color: AppColors.textGrey),
                const Gap(3),
                Text(
                  _formatDate(resume.updatedAt),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textGrey),
        const Gap(2),
        Text(
          value == 'true' ? 'Yes' : value == 'false' ? 'No' : value,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, fontSize: 10),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}

extension on _Filter {
  String get label {
    switch (this) {
      case _Filter.all:
        return 'All';
      case _Filter.recent:
        return 'Recent';
      case _Filter.favorites:
        return 'Top Rated';
    }
  }
}
