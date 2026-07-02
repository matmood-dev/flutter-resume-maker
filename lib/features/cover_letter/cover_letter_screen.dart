import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/resume_provider.dart';
import '../../providers/ai_provider.dart';

class CoverLetterScreen extends ConsumerStatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  ConsumerState<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends ConsumerState<CoverLetterScreen> {
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  String? _selectedResumeId;
  bool _showLetter = false;
  String _generatedLetter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resumeProvider.notifier).loadResumes();
    });
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _generateLetter() {
    if (_companyController.text.isEmpty ||
        _positionController.text.isEmpty ||
        _selectedResumeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: AppTextStyles.bodyMedium,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final company = _companyController.text;
    final position = _positionController.text;

    final prompt =
        'Write a professional cover letter for a $position position at $company. '
        'Make it tailored, confident, and concise. Highlight relevant skills and enthusiasm.';

    ref.read(aiProvider.notifier).generateContent(prompt: prompt).then((result) {
      if (result.isNotEmpty) {
        setState(() {
          _generatedLetter = result;
          _showLetter = true;
        });
        _saveCoverLetter(result);
      }
    });
  }

  Future<void> _saveCoverLetter(String content) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('cover_letters').insert({
        'user_id': user.id,
        'resume_id': _selectedResumeId,
        'company_name': _companyController.text,
        'position': _positionController.text,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save cover letter',
              style: AppTextStyles.bodyMedium,
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _regenerate() {
    setState(() {
      _showLetter = false;
      _generatedLetter = '';
    });
    _generateLetter();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedLetter));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cover letter copied to clipboard',
          style: AppTextStyles.bodyMedium,
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: Text('Cover Letter', style: AppTextStyles.headlineMedium),
        centerTitle: true,
      ),
      body: _showLetter ? _buildGeneratedLetter() : _buildInputForm(aiState),
    );
  }

  Widget _buildInputForm(AiState aiState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate a tailored cover letter using AI',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
          const Gap(24),
          _buildInputField(
            label: 'Company Name',
            controller: _companyController,
            hint: 'e.g., Google, Meta, Apple',
          ),
          const Gap(16),
          _buildInputField(
            label: 'Position',
            controller: _positionController,
            hint: 'e.g., Senior Software Engineer',
          ),
          const Gap(16),
          _buildResumeDropdown(),
          const Gap(32),
          _buildGenerateButton(aiState),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleSmall),
        const Gap(8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumeDropdown() {
    final resumeState = ref.watch(resumeProvider);
    final resumes = resumeState.resumes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Resume', style: AppTextStyles.titleSmall),
        const Gap(8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedResumeId,
            dropdownColor: AppColors.card,
            style: AppTextStyles.bodyMedium,
            icon:
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey),
            decoration: InputDecoration(
              hintText: 'Choose a resume',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            items: resumes.map((resume) {
              return DropdownMenuItem(
                value: resume.id,
                child: Text(resume.title),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedResumeId = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(AiState aiState) {
    final isGenerating = aiState.isGenerating;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isGenerating ? null : _generateLetter,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: AppColors.primary.withAlpha(100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isGenerating
                ? null
                : const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: isGenerating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textWhite,
                          ),
                        ),
                      ),
                      const Gap(12),
                      Text(
                        'Generating...',
                        style: AppTextStyles.buttonLarge,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, size: 20),
                      const Gap(8),
                      Text(
                        'Generate with AI',
                        style: AppTextStyles.buttonLarge,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedLetter() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLetterCard(),
          const Gap(20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildLetterCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _companyController.text,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.background,
                  ),
                ),
                const Gap(4),
                Text(
                  _positionController.text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.background.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _generatedLetter,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textWhite,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.copy_outlined,
            label: 'Copy',
            onTap: _copyToClipboard,
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.picture_as_pdf_outlined,
            label: 'Download PDF',
            onTap: () {},
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.refresh,
            label: 'Regenerate',
            onTap: _regenerate,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const Gap(6),
            Text(
              label,
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
