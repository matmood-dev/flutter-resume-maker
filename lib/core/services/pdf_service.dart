import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../../models/resume_model.dart';

class PdfTemplateStyle {
  final String templateStyle;
  final PdfColor primaryColor;
  final PdfColor secondaryColor;
  final PdfColor headerBgColor;
  final double nameFontSize;
  final double sectionHeaderFontSize;
  final double bodyFontSize;
  final bool isTwoColumn;
  final List<String> sectionOrder;

  PdfTemplateStyle({
    required this.templateStyle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.headerBgColor,
    required this.nameFontSize,
    required this.sectionHeaderFontSize,
    required this.bodyFontSize,
    required this.isTwoColumn,
    required this.sectionOrder,
  });
}

class PdfService {
  static final DateFormat _dateFormatter = DateFormat('MMM yyyy');

  static final Map<String, PdfTemplateStyle> _templateStyles = {
    'modern': PdfTemplateStyle(
      templateStyle: 'modern',
      primaryColor: PdfColor.fromHex('#76C8FF'),
      secondaryColor: PdfColor.fromHex('#E8F4FD'),
      headerBgColor: PdfColor.fromHex('#76C8FF'),
      nameFontSize: 28,
      sectionHeaderFontSize: 14,
      bodyFontSize: 10,
      isTwoColumn: true,
      sectionOrder: const [
        'summary',
        'experience',
        'education',
        'skills',
        'projects',
        'certificates',
        'languages',
      ],
    ),
    'professional': PdfTemplateStyle(
      templateStyle: 'professional',
      primaryColor: PdfColor.fromHex('#1a1a2e'),
      secondaryColor: PdfColor.fromHex('#16213e'),
      headerBgColor: PdfColor.fromHex('#1a1a2e'),
      nameFontSize: 26,
      sectionHeaderFontSize: 13,
      bodyFontSize: 10,
      isTwoColumn: false,
      sectionOrder: const [
        'summary',
        'experience',
        'education',
        'skills',
        'projects',
        'certificates',
        'languages',
      ],
    ),
    'creative': PdfTemplateStyle(
      templateStyle: 'creative',
      primaryColor: PdfColor.fromHex('#FF9800'),
      secondaryColor: PdfColor.fromHex('#FFF3E0'),
      headerBgColor: PdfColor.fromHex('#FF9800'),
      nameFontSize: 30,
      sectionHeaderFontSize: 14,
      bodyFontSize: 10,
      isTwoColumn: true,
      sectionOrder: const [
        'summary',
        'skills',
        'experience',
        'projects',
        'education',
        'certificates',
        'languages',
      ],
    ),
    'minimal': PdfTemplateStyle(
      templateStyle: 'minimal',
      primaryColor: PdfColor.fromHex('#9E9E9E'),
      secondaryColor: PdfColor.fromHex('#F5F5F5'),
      headerBgColor: PdfColor.fromHex('#FFFFFF'),
      nameFontSize: 24,
      sectionHeaderFontSize: 12,
      bodyFontSize: 10,
      isTwoColumn: false,
      sectionOrder: const [
        'summary',
        'experience',
        'education',
        'skills',
        'projects',
        'certificates',
        'languages',
      ],
    ),
    'executive': PdfTemplateStyle(
      templateStyle: 'executive',
      primaryColor: PdfColor.fromHex('#9C7CFF'),
      secondaryColor: PdfColor.fromHex('#F3EEFF'),
      headerBgColor: PdfColor.fromHex('#9C7CFF'),
      nameFontSize: 28,
      sectionHeaderFontSize: 14,
      bodyFontSize: 10,
      isTwoColumn: true,
      sectionOrder: const [
        'summary',
        'experience',
        'education',
        'projects',
        'skills',
        'certificates',
        'languages',
      ],
    ),
    'ats_friendly': PdfTemplateStyle(
      templateStyle: 'ats_friendly',
      primaryColor: PdfColor.fromHex('#000000'),
      secondaryColor: PdfColor.fromHex('#F0F0F0'),
      headerBgColor: PdfColor.fromHex('#FFFFFF'),
      nameFontSize: 24,
      sectionHeaderFontSize: 12,
      bodyFontSize: 10,
      isTwoColumn: false,
      sectionOrder: const [
        'summary',
        'experience',
        'education',
        'skills',
        'projects',
        'certificates',
        'languages',
      ],
    ),
  };

  static String getTemplateName(String style) {
    const names = {
      'modern': 'Modern',
      'professional': 'Professional',
      'creative': 'Creative',
      'minimal': 'Minimal',
      'executive': 'Executive',
      'ats_friendly': 'ATS Friendly',
    };
    return names[style] ?? 'Unknown';
  }

  static PdfTemplateStyle _getStyle(String templateStyle) {
    return _templateStyles[templateStyle] ?? _templateStyles['professional']!;
  }

  static Future<Uint8List> generateResumePdf(
    ResumeModel resume,
    String templateStyle,
  ) async {
    final style = _getStyle(templateStyle);
    final doc = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final fontItalic = pw.Font.helveticaOblique();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        build: (context) {
          final sections = <pw.Widget>[];

          sections.add(_buildHeader(resume, style, font, fontBold));
          sections.add(pw.SizedBox(height: 12));

          for (final section in style.sectionOrder) {
            final widget = _buildSection(
              section,
              resume,
              style,
              font,
              fontBold,
              fontItalic,
            );
            if (widget != null) {
              sections.add(widget);
              sections.add(pw.SizedBox(height: 10));
            }
          }

          return sections;
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(
    ResumeModel resume,
    PdfTemplateStyle style,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final info = resume.personalInfo;
    final contactItems = <String>[];

    if (info.email.isNotEmpty) contactItems.add(info.email);
    if (info.phoneNumber.isNotEmpty) contactItems.add(info.phoneNumber);
    if (info.address != null && info.address!.isNotEmpty) {
      contactItems.add(info.address!);
    }
    if (info.linkedIn != null && info.linkedIn!.isNotEmpty) {
      contactItems.add(info.linkedIn!);
    }
    if (info.portfolioUrl != null && info.portfolioUrl!.isNotEmpty) {
      contactItems.add(info.portfolioUrl!);
    }

    if (style.templateStyle == 'ats_friendly' ||
        style.templateStyle == 'minimal') {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            info.fullName,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: style.nameFontSize,
              color: PdfColors.black,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            contactItems.join(' | '),
            style: pw.TextStyle(
              font: font,
              fontSize: style.bodyFontSize,
              color: PdfColor.fromHex('#444444'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Divider(
            color: style.primaryColor,
            thickness: 1.5,
          ),
        ],
      );
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: style.headerBgColor,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            info.fullName,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: style.nameFontSize,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            contactItems.join('  •  '),
            style: pw.TextStyle(
              font: font,
              fontSize: style.bodyFontSize - 1,
              color: PdfColor.fromHex('#E0E0E0'),
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static pw.Widget? _buildSection(
    String section,
    ResumeModel resume,
    PdfTemplateStyle style,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontItalic,
  ) {
    switch (section) {
      case 'summary':
        return _buildSummary(resume, style, font, fontBold);
      case 'experience':
        return _buildExperience(resume, style, font, fontBold, fontItalic);
      case 'education':
        return _buildEducation(resume, style, font, fontBold);
      case 'skills':
        return _buildSkills(resume, style, font, fontBold);
      case 'projects':
        return _buildProjects(resume, style, font, fontBold, fontItalic);
      case 'certificates':
        return _buildCertificates(resume, style, font, fontBold);
      case 'languages':
        return _buildLanguages(resume, style, font, fontBold);
      default:
        return null;
    }
  }

  static pw.Widget _buildSummary(
    ResumeModel resume,
    PdfTemplateStyle style,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (resume.summary.isEmpty) return pw.SizedBox.shrink();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('Professional Summary', style, fontBold),
        pw.SizedBox(height: 6),
        pw.Text(
          resume.summary,
          style: pw.TextStyle(
            font: font,
            fontSize: style.bodyFontSize,
            color: PdfColor.fromHex('#333333'),
            lineSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildExperience(
    ResumeModel resume,
    PdfTemplateStyle style,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontItalic,
  ) {
    if (resume.experience.isEmpty) return pw.SizedBox.shrink();

    final items = resume.experience.map((exp) {
      final dateRange = _formatDateRange(exp.startDate, exp.endDate, exp.isCurrent);

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      exp.position,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: style.bodyFontSize + 1,
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      exp.company,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: style.bodyFontSize,
                        color: style.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Text(
                dateRange,
                style: pw.TextStyle(
                  font: fontItalic,
                  fontSize: style.bodyFontSize - 1,
                  color: PdfColor.fromHex('#666666'),
                ),
              ),
            ],
          ),
          if (exp.responsibilities.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: exp.responsibilities.map((resp) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '•  ',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: style.bodyFontSize,
                          color: PdfColor.fromHex('#555555'),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          resp,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: style.bodyFontSize,
                            color: PdfColor.fromHex('#333333'),
                            lineSpacing: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      );
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('Experience', style, fontBold),
        pw.SizedBox(height: 6),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: _intersperse(items, pw.SizedBox(height: 10)),
        ),
      ],
    );
  }

  static pw.Widget _buildEducation(
    ResumeModel resume,
    PdfTemplateStyle style,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (resume.education.isEmpty) return pw.SizedBox.shrink();

    final items = resume.education.map((edu) {
      final gradDate = _dateFormatter.format(edu.graduationDate);
      final degreeText =
          '${edu.degree} in ${edu.major}';
      final gpaText = edu.gpa != null ? '  |  GPA: ${edu.gpa!.toStringAsFixed(1)}' : '';

      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  edu.school,
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: style.bodyFontSize + 1,
                    color: PdfColors.black,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Row(
                  children: [
                    pw.Text(
                      degreeText,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: style.bodyFontSize,
                        color: PdfColor.fromHex('#333333'),
                      ),
                    ),
                    if (gpaText.isNotEmpty)
                      pw.Text(
                        gpaText,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: style.bodyFontSize - 1,
                          color: PdfColor.fromHex('#666666'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          pw.Text(
            gradDate,
            style: pw.TextStyle(
              font: font,
              fontSize: style.bodyFontSize - 1,
              color: PdfColor.fromHex('#666666'),
            ),
          ),
        ],
      );
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('Education', style, fontBold),
        pw.SizedBox(height: 6),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: _intersperse(items, pw.SizedBox(height: 8)),
        ),
      ],
    );
  }

  static pw.Widget _buildSkills(
    ResumeModel resume,
    PdfTemplateStyle style,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (resume.skills.isEmpty) return pw.SizedBox.shrink();

    if (style.isTwoColumn) {
      final half = (resume.skills.length / 2).ceil();
      final col1 = resume.skills.sublist(0, half);
      final col2 = resume.skills.sublist(half);

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionHeader('Skills', style, fontBold),
          pw.SizedBox(height: 6),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: col1.map((s) => _skillItem(s, style, font)).toList(),
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: col2.map((s) => _skillItem(s, style, font)).toList(),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('Skills', style, fontBold),
        pw.SizedBox(height: 6),
        pw.Wrap(
          spacing: 8,
          runSpacing: 6,
          children: resume.skills.map((skill) {
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: pw.BoxDecoration(
                color: style.secondaryColor,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: style.primaryColor, width: 0.5),
              ),
              child: pw.Text(
                skill,
                style: pw.TextStyle(
                  font: font,
                  fontSize: style.bodyFontSize - 1,
                  color: PdfColor.fromHex('#333333'),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static pw.Widget _skillItem(
    String skill,
    PdfTemplateStyle style,
    pw.Font font,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '•  ',
            style: pw.TextStyle(
              font: font,
              fontSize: style.bodyFontSize,
              color: style.primaryColor,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              skill,
              style: pw.TextStyle(
                font: font,
                fontSize: style.bodyFontSize,
                color: PdfColor.fromHex('#333333'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProjects(
    ResumeModel resume,
    PdfTemplateStyle style,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontItalic,
  ) {
    if (resume.projects.isEmpty) return pw.SizedBox.shrink();

    final items = resume.projects.map((proj) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            proj.name,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: style.bodyFontSize + 1,
              color: PdfColors.black,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            proj.description,
            style: pw.TextStyle(
              font: font,
              fontSize: style.bodyFontSize,
              color: PdfColor.fromHex('#333333'),
              lineSpacing: 1.3,
            ),
          ),
          if (proj.technologies.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Wrap(
              spacing: 6,
              runSpacing: 4,
              children: proj.technologies.map((tech) {
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: pw.BoxDecoration(
                    color: style.secondaryColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    tech,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: style.bodyFontSize - 2,
                      color: PdfColor.fromHex('#555555'),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (proj.githubLink != null && proj.githubLink!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              proj.githubLink!,
              style: pw.TextStyle(
                font: fontItalic,
                fontSize: style.bodyFontSize - 2,
                color: style.primaryColor,
              ),
            ),
          ],
        ],
      );
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('Projects', style, fontBold),
        pw.SizedBox(height: 6),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: _intersperse(items, pw.SizedBox(height: 8)),
        ),
      ],
    );
  }

  static pw.Widget _buildCertificates(
    ResumeModel resume,
    PdfTemplateStyle style,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (resume.certificates.isEmpty) return pw.SizedBox.shrink();

    final items = resume.certificates.map((cert) {
      final dateStr = _dateFormatter.format(cert.date);

      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  cert.name,
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: style.bodyFontSize,
                    color: PdfColors.black,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.Text(
                  cert.organization,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: style.bodyFontSize - 1,
                    color: PdfColor.fromHex('#555555'),
                  ),
                ),
              ],
            ),
          ),
          pw.Text(
            dateStr,
            style: pw.TextStyle(
              font: font,
              fontSize: style.bodyFontSize - 1,
              color: PdfColor.fromHex('#666666'),
            ),
          ),
        ],
      );
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('Certifications', style, fontBold),
        pw.SizedBox(height: 6),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: _intersperse(items, pw.SizedBox(height: 6)),
        ),
      ],
    );
  }

  static pw.Widget _buildLanguages(
    ResumeModel resume,
    PdfTemplateStyle style,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (resume.languages.isEmpty) return pw.SizedBox.shrink();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('Languages', style, fontBold),
        pw.SizedBox(height: 6),
        pw.Wrap(
          spacing: 12,
          runSpacing: 4,
          children: resume.languages.map((lang) {
            return pw.Text(
              lang,
              style: pw.TextStyle(
                font: font,
                fontSize: style.bodyFontSize,
                color: PdfColor.fromHex('#333333'),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static pw.Widget _sectionHeader(
    String title,
    PdfTemplateStyle style,
    pw.Font fontBold,
  ) {
    if (style.templateStyle == 'ats_friendly') {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              font: fontBold,
              fontSize: style.sectionHeaderFontSize,
              color: PdfColors.black,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Divider(
            color: PdfColors.black,
            thickness: 1,
          ),
        ],
      );
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: style.primaryColor,
            width: 1.5,
          ),
        ),
      ),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          font: fontBold,
          fontSize: style.sectionHeaderFontSize,
          color: style.primaryColor,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static String _formatDateRange(
    DateTime start,
    DateTime? end,
    bool isCurrent,
  ) {
    final startStr = _dateFormatter.format(start);
    if (isCurrent) return '$startStr – Present';
    if (end == null) return startStr;
    final endStr = _dateFormatter.format(end);
    return '$startStr – $endStr';
  }

  static List<T> _intersperse<T>(List<T> list, T separator) {
    if (list.length <= 1) return list;
    final result = <T>[];
    for (var i = 0; i < list.length; i++) {
      result.add(list[i]);
      if (i < list.length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}
