import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnalyzing = false;
  bool _showResults = false;
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 87).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _simulateUpload() {
    setState(() {
      _isAnalyzing = true;
      _showResults = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isAnalyzing = false;
        _showResults = true;
      });
      _controller.forward();
    });
  }

  void _resetScan() {
    _controller.reset();
    setState(() {
      _showResults = false;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: Text('Resume Scanner', style: AppTextStyles.headlineMedium),
        centerTitle: true,
      ),
      body: _showResults ? _buildResults() : _buildUploadArea(),
    );
  }

  Widget _buildUploadArea() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Gap(40),
          GestureDetector(
            onTap: _isAnalyzing ? null : _simulateUpload,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 260,
              decoration: BoxDecoration(
                color: _isAnalyzing
                    ? AppColors.primary.withAlpha(15)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isAnalyzing
                      ? AppColors.primary
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: _isAnalyzing ? _buildAnalyzingState() : _buildUploadPrompt(),
            ),
          ),
          const Gap(32),
          Text(
            'Upload your resume to get an ATS compatibility score and actionable improvement suggestions.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureChip(Icons.speed, 'ATS Score'),
              const Gap(12),
              _buildFeatureChip(Icons.format_list_bulleted, 'Breakdown'),
              const Gap(12),
              _buildFeatureChip(Icons.lightbulb_outline, 'Tips'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            color: AppColors.primary,
            size: 36,
          ),
        ),
        const Gap(16),
        Text('Tap to upload PDF', style: AppTextStyles.titleMedium),
        const Gap(8),
        Text(
          'Supports PDF files up to 10MB',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildAnalyzingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const Gap(16),
        Text('Analyzing your resume...', style: AppTextStyles.titleMedium),
        const Gap(8),
        Text(
          'This may take a few seconds',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const Gap(6),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildScoreCircle(),
          const Gap(24),
          _buildScoreBreakdown(),
          const Gap(24),
          _buildSuggestions(),
          const Gap(24),
          _buildScanAnotherButton(),
          const Gap(20),
        ],
      ),
    );
  }

  Widget _buildScoreCircle() {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        final score = _scoreAnimation.value.round();
        return Column(
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _scoreAnimation.value / 100,
                      strokeWidth: 10,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(_scoreAnimation.value),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score%',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: _getScoreColor(_scoreAnimation.value),
                        ),
                      ),
                      Text(
                        'ATS Score',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(16),
            Text(
              _getScoreLabel(_scoreAnimation.value),
              style: AppTextStyles.titleMedium.copyWith(
                color: _getScoreColor(_scoreAnimation.value),
              ),
            ),
            const Gap(4),
            Text(
              'Your resume is well-optimized for ATS systems',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreBreakdown() {
    final items = [
      _BreakdownItem(label: 'Formatting', score: 92, color: AppColors.success),
      _BreakdownItem(label: 'Keywords', score: 85, color: AppColors.primary),
      _BreakdownItem(label: 'Skills', score: 78, color: AppColors.warning),
      _BreakdownItem(label: 'Grammar', score: 95, color: AppColors.success),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Score Breakdown', style: AppTextStyles.titleLarge),
        const Gap(12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBreakdownCard(item),
            )),
      ],
    );
  }

  Widget _buildBreakdownCard(_BreakdownItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.label, style: AppTextStyles.titleSmall),
              Text(
                '${item.score}%',
                style: AppTextStyles.titleSmall.copyWith(color: item.color),
              ),
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.score / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      _SuggestionItem(
        icon: Icons.add_circle_outline,
        text: 'Add missing keywords: "Agile", "CI/CD", "Microservices"',
        type: _SuggestionType.warning,
      ),
      _SuggestionItem(
        icon: Icons.check_circle_outline,
        text: 'Strong action verbs detected throughout',
        type: _SuggestionType.success,
      ),
      _SuggestionItem(
        icon: Icons.lightbulb_outline,
        text: 'Include quantifiable achievements (e.g., "increased revenue by 20%")',
        type: _SuggestionType.info,
      ),
      _SuggestionItem(
        icon: Icons.warning_amber_outlined,
        text: 'Remove outdated technologies: Flash, jQuery',
        type: _SuggestionType.warning,
      ),
      _SuggestionItem(
        icon: Icons.check_circle_outline,
        text: 'Contact information is properly formatted',
        type: _SuggestionType.success,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suggestions', style: AppTextStyles.titleLarge),
        const Gap(12),
        ...suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildSuggestionCard(s),
            )),
      ],
    );
  }

  Widget _buildSuggestionCard(_SuggestionItem item) {
    Color iconColor;
    switch (item.type) {
      case _SuggestionType.success:
        iconColor = AppColors.success;
        break;
      case _SuggestionType.warning:
        iconColor = AppColors.warning;
        break;
      case _SuggestionType.info:
        iconColor = AppColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: iconColor, size: 20),
          const Gap(12),
          Expanded(
            child: Text(
              item.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textWhite,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanAnotherButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _resetScan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Scan Another',
          style: AppTextStyles.buttonLarge.copyWith(color: AppColors.background),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Great!';
    if (score >= 60) return 'Good';
    return 'Needs Improvement';
  }
}

enum _SuggestionType { success, warning, info }

class _BreakdownItem {
  final String label;
  final int score;
  final Color color;

  const _BreakdownItem({
    required this.label,
    required this.score,
    required this.color,
  });
}

class _SuggestionItem {
  final IconData icon;
  final String text;
  final _SuggestionType type;

  const _SuggestionItem({
    required this.icon,
    required this.text,
    required this.type,
  });
}
