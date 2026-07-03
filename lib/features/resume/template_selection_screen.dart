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
  Uint8List? _pdfBytes;
  String? _error;

  static const _templates = [
    (
      name: 'Modern',
      key: 'modern',
      description: 'Two-column with dark sidebar and yellow accent',
      icon: Icons.view_column_outlined,
      color: Color(0xFF2A2A2A),
    ),
    (
      name: 'ATS Friendly',
      key: 'ats',
      description: 'Simple single-column, optimized for ATS scanners',
      icon: Icons.description_outlined,
      color: Color(0xFF374151),
    ),
  ];

  Future<void> _generatePdf() async {
    setState(() {
      _isGenerating = true;
      _error = null;
      _pdfBytes = null;
    });

    try {
      final templateKey = _templates[_selectedIndex].key;
      final pdfBytes = await PdfService.generateResumePdf(
        widget.resume,
        templateName: templateKey,
      );

      if (mounted) {
        setState(() {
          _pdfBytes = pdfBytes;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isGenerating = false;
        });
      }
    }
  }

  void _previewPdf() {
    if (_pdfBytes == null) return;
    Printing.layoutPdf(
      onLayout: (format) async => _pdfBytes!,
      name: '${widget.resume.title}.pdf',
    );
  }

  void _downloadPdf() {
    if (_pdfBytes == null) return;
    Printing.sharePdf(
      bytes: _pdfBytes!,
      filename: '${widget.resume.title}.pdf',
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
        title: Text('Choose Template', style: AppTextStyles.headlineMedium),
      ),
      body: Column(
        children: [
          Expanded(
            child: _pdfBytes == null && !_isGenerating
                ? _buildTemplateSelection()
                : _isGenerating
                    ? _buildLoadingState()
                    : _error != null
                        ? _buildErrorState()
                        : _buildPreviewState(),
          ),
          if (_pdfBytes == null && !_isGenerating) _buildGenerateButton(),
          if (_pdfBytes != null) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTemplateSelection() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Text('Select a Template', style: AppTextStyles.displaySmall),
        const Gap(4),
        Text(
          'Choose a style for your resume',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
        ),
        const Gap(24),
        ...List.generate(_templates.length, (index) {
          final template = _templates[index];
          final isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
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
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: template.color.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(template.icon, color: template.color, size: 24),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textWhite,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            template.description,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          Gap(20),
          Text('Generating your resume...', style: TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const Gap(16),
            Text('Failed to generate PDF', style: AppTextStyles.headlineSmall),
            const Gap(8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: _generatePdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(
                _templates[_selectedIndex].icon,
                color: AppColors.primary,
                size: 20,
              ),
              const Gap(8),
              Text(
                '${_templates[_selectedIndex].name} Template',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _pdfBytes = null;
                  _error = null;
                }),
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        Expanded(
          child: PdfPreview(
            onPrinted: (details) {},
            actions: [],
            build: (format) async => _pdfBytes!,
          ),
        ),
      ],
    );
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
            onPressed: _generatePdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Generate PDF', style: AppTextStyles.buttonMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _previewPdf,
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('Preview'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _downloadPdf,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
