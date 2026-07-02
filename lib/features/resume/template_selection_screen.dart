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
  bool _isGenerating = true;
  Uint8List? _pdfBytes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final pdfBytes = await PdfService.generateResumePdf(widget.resume);

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
        title: Text('Preview Resume', style: AppTextStyles.headlineMedium),
        actions: [
          if (_pdfBytes != null)
            IconButton(
              onPressed: _downloadPdf,
              icon: const Icon(Icons.download, color: AppColors.primary),
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _pdfBytes != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isGenerating) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_pdfBytes != null) {
      return _buildSuccessState();
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          Gap(20),
          Text(
            'Generating your resume...',
            style: TextStyle(color: AppColors.textGrey),
          ),
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
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const Gap(16),
            Text(
              'Failed to generate PDF',
              style: AppTextStyles.headlineSmall,
            ),
            const Gap(8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
              ),
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

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const Gap(24),
            Text(
              'Resume Generated!',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textWhite,
              ),
            ),
            const Gap(8),
            Text(
              '${widget.resume.title}.pdf',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
              ),
            ),
            const Gap(8),
            Text(
              'Tap Preview to view or Download to save',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
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
