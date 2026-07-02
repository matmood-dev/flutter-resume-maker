import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/pdf_service.dart';
import '../../models/resume_model.dart';

class TemplateSelectionScreen extends ConsumerStatefulWidget {
  final ResumeModel resume;

  const TemplateSelectionScreen({super.key, required this.resume});

  @override
  ConsumerState<TemplateSelectionScreen> createState() =>
      _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState
    extends ConsumerState<TemplateSelectionScreen> {
  int _selectedIndex = 0;
  bool _isGenerating = false;

  static const _templates = [
    (
      name: 'Modern',
      category: 'Two-Column',
      color: Color(0xFF76C8FF),
      icon: Icons.view_column_outlined,
    ),
    (
      name: 'Professional',
      category: 'Formal',
      color: Color(0xFF1A1A2E),
      icon: Icons.business_center_outlined,
    ),
    (
      name: 'Creative',
      category: 'Sidebar',
      color: Color(0xFFFF9800),
      icon: Icons.dashboard_outlined,
    ),
    (
      name: 'Minimal',
      category: 'Clean',
      color: Color(0xFF9E9E9E),
      icon: Icons.article_outlined,
    ),
    (
      name: 'Executive',
      category: 'Elegant',
      color: Color(0xFF9C7CFF),
      icon: Icons.workspace_premium_outlined,
    ),
    (
      name: 'ATS Friendly',
      category: 'Simple',
      color: Color(0xFF424242),
      icon: Icons.description_outlined,
    ),
  ];

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);

    try {
      final pdfBytes = await PdfService.generateResumePdf(
        widget.resume,
        _templates[_selectedIndex].name,
      );

      if (mounted) {
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: '${widget.resume.title}.pdf',
        );

        if (mounted) {
          _showDownloadShareSheet(pdfBytes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showDownloadShareSheet(Uint8List pdfBytes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(20),
              Text('PDF Generated', style: AppTextStyles.headlineSmall),
              const Gap(4),
              Text(
                'Preview and download your resume',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
              const Gap(24),
              ListTile(
                leading: const Icon(Icons.visibility, color: AppColors.primary),
                title: Text('Preview', style: AppTextStyles.titleSmall),
                subtitle: Text(
                  'View the generated PDF',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Printing.layoutPdf(
                    onLayout: (format) async => pdfBytes,
                    name: '${widget.resume.title}.pdf',
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Gap(8),
              ListTile(
                leading: const Icon(Icons.download, color: AppColors.success),
                title: Text('Download', style: AppTextStyles.titleSmall),
                subtitle: Text(
                  'Save to your device',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: '${widget.resume.title}.pdf',
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Gap(8),
              ListTile(
                leading: const Icon(Icons.share, color: AppColors.accent),
                title: Text('Share', style: AppTextStyles.titleSmall),
                subtitle: Text(
                  'Send to others',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: '${widget.resume.title}.pdf',
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
        ),
        title: Text('Template', style: AppTextStyles.headlineMedium),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Gap(8),
                Text('Choose a Template', style: AppTextStyles.displaySmall),
                const Gap(4),
                Text(
                  'Select a style for your resume',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                const Gap(24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) =>
                      _buildTemplateCard(index),
                ),
                const Gap(24),
              ],
            ),
          ),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(int index) {
    final template = _templates[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(51),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: template.color.withAlpha(26),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildPreviewLayout(template),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      template.name,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textWhite,
                      ),
                    ),
                    const Gap(4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withAlpha(38)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        template.category,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textGrey,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewLayout(dynamic template) {
    final color = template.color as Color;
    final icon = template.icon as IconData;
    final name = template.name as String;

    switch (name) {
      case 'Modern':
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 6,
                      width: 36,
                      decoration: BoxDecoration(
                        color: color.withAlpha(128),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const Gap(8),
                    ...List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              height: 3,
                              width: 24 + (i * 4).toDouble(),
                              decoration: BoxDecoration(
                                color: color.withAlpha(77),
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              color: color.withAlpha(51),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(
                      4,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Container(
                              height: 2,
                              width: 28 + (i * 6).toDouble(),
                              decoration: BoxDecoration(
                                color: color.withAlpha(51),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 'Professional':
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color.withAlpha(128),
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(6),
              Container(
                height: 3,
                width: 28,
                decoration: BoxDecoration(
                  color: color.withAlpha(77),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const Gap(2),
              Container(
                height: 2,
                width: 20,
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const Gap(8),
              ...List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Container(
                    height: 2,
                    width: 44,
                    decoration: BoxDecoration(
                      color: color.withAlpha(51),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'Creative':
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(15)),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color.withAlpha(77),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(6),
                    ...List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Container(
                          height: 2,
                          width: 20,
                          decoration: BoxDecoration(
                            color: color.withAlpha(51),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(
                      4,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Container(
                          height: 2,
                          width: 26 + (i * 4).toDouble(),
                          decoration: BoxDecoration(
                            color: color.withAlpha(51),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 'Minimal':
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
                width: 32,
                decoration: BoxDecoration(
                  color: color.withAlpha(102),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(10),
              ...List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    height: 2,
                    width: 38,
                    decoration: BoxDecoration(
                      color: color.withAlpha(51),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'Executive':
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 2,
                    width: 12,
                    decoration: BoxDecoration(
                      color: color.withAlpha(153),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const Gap(6),
                  Container(
                    height: 2,
                    width: 24,
                    decoration: BoxDecoration(
                      color: color.withAlpha(102),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
              const Gap(4),
              Container(
                height: 1,
                width: double.infinity,
                color: color.withAlpha(51),
              ),
              const Gap(8),
              ...List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    height: 2,
                    width: 34,
                    decoration: BoxDecoration(
                      color: color.withAlpha(51),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'ATS Friendly':
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Container(
                    height: 2,
                    width: i == 0 ? 30 : 36,
                    decoration: BoxDecoration(
                      color: color.withAlpha(51),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return Icon(icon, size: 32, color: color.withAlpha(128));
    }
  }

  Widget _buildGenerateButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _generatePdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: AppColors.background,
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: AppColors.textGrey,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isGenerating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.background,
                      strokeWidth: 2,
                    ),
                  )
                : Text('Generate PDF', style: AppTextStyles.buttonMedium),
          ),
        ),
      ),
    );
  }
}
