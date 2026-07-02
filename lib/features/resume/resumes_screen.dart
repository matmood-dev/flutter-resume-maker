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
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resumeProvider.notifier).loadResumes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text('My Resumes', style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            onPressed: () => context.push('/resume/create'),
            icon: const Icon(Icons.add, color: AppColors.primary, size: 28),
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          const Gap(16),
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : state.resumes.isEmpty
                    ? _buildEmptyState()
                    : _buildResumeGrid(state.resumes),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/resume/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.background, size: 28),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _Filter.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.textWhite : AppColors.textGrey,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.card,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (_) => setState(() => _selectedFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResumeGrid(List resumes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: resumes.length,
        itemBuilder: (context, index) {
          final resume = resumes[index];
          return _ResumeCard(
            resume: resume,
            onTap: () => context.push('/resume/create'),
            onDelete: () =>
                ref.read(resumeProvider.notifier).deleteResume(resume.id),
          );
        },
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const Gap(24),
            Text('No Resumes Yet', style: AppTextStyles.headlineMedium),
            const Gap(8),
            Text(
              'Create your first resume and land your dream job with AI-powered insights.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textGrey),
            ),
            const Gap(24),
            ElevatedButton.icon(
              onPressed: () => context.push('/resume/create'),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    resume.title,
                    style: AppTextStyles.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textGrey,
                    size: 20,
                  ),
                  color: AppColors.surface,
                  onSelected: (value) {
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit', style: AppTextStyles.bodyMedium),
                    ),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate', style: AppTextStyles.bodyMedium),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(8),
            Text(
              'Template: ${resume.templateId ?? 'None'}',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
            const Spacer(),
            if (score != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ATS ${score.round()}',
                  style: AppTextStyles.labelSmall.copyWith(color: scoreColor),
                ),
              ),
            const Gap(8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: AppColors.textGrey),
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
}

extension on _Filter {
  String get label {
    switch (this) {
      case _Filter.all:
        return 'All';
      case _Filter.recent:
        return 'Recent';
      case _Filter.favorites:
        return 'Favorites';
    }
  }
}
