import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  String? _selectedResume;
  bool _isGenerating = false;
  bool _showLetter = false;

  final _resumes = const [
    'Senior Developer Resume',
    'Product Manager CV',
    'UI/UX Designer Resume',
  ];

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _generateLetter() {
    if (_companyController.text.isEmpty ||
        _positionController.text.isEmpty ||
        _selectedResume == null) {
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

    setState(() {
      _isGenerating = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isGenerating = false;
        _showLetter = true;
      });
    });
  }

  void _regenerate() {
    setState(() {
      _showLetter = false;
    });
    _generateLetter();
  }

  void _copyToClipboard() {
    final letter = _getCoverLetterText();
    Clipboard.setData(ClipboardData(text: letter));
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

  String _getCoverLetterText() {
    final company = _companyController.text;
    final position = _positionController.text;
    return '''Dear Hiring Manager,

I am writing to express my strong interest in the $position position at $company. With a proven track record of delivering high-quality solutions and a passion for innovation, I am confident that my skills and experience align perfectly with your team's needs.

In my previous roles, I have successfully led cross-functional teams, implemented scalable architectures, and delivered impactful products that drove measurable business outcomes. My expertise in modern technologies, combined with my strong problem-solving abilities, positions me to make an immediate contribution to your organization.

I am particularly drawn to $company's mission and innovative approach to the industry. I believe my technical skills, combined with my strong communication and collaboration abilities, make me an ideal candidate for this role.

I would welcome the opportunity to discuss how my background, skills, and enthusiasm can contribute to the continued success of $company. Thank you for considering my application.

Best regards,
Matt''';
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
        title: Text('Cover Letter', style: AppTextStyles.headlineMedium),
        centerTitle: true,
      ),
      body: _showLetter ? _buildGeneratedLetter() : _buildInputForm(),
    );
  }

  Widget _buildInputForm() {
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
          _buildGenerateButton(),
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
            initialValue: _selectedResume,
            dropdownColor: AppColors.card,
            style: AppTextStyles.bodyMedium,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey),
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
            items: _resumes.map((resume) {
              return DropdownMenuItem(
                value: resume,
                child: Text(resume),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedResume = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateLetter,
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
            gradient: _isGenerating
                ? null
                : const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isGenerating
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
              _getCoverLetterText(),
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
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
