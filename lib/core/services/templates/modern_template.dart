import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../../models/resume_model.dart';

class ModernTemplate {
  static final DateFormat _dateFormatter = DateFormat('yyyy');

  static final PdfColor _sidebarBg = PdfColor.fromHex('#2A2A2A');
  static final PdfColor _accent = PdfColor.fromHex('#FFD60A');
  static final PdfColor _textDark = PdfColor.fromHex('#1A1A1A');
  static final PdfColor _textGray = PdfColor.fromHex('#666666');
  static final PdfColor _textLightGray = PdfColor.fromHex('#999999');
  static final PdfColor _divider = PdfColor.fromHex('#E0E0E0');
  static final PdfColor _skillBarBg = PdfColor.fromHex('#555555');
  static final PdfColor _skillBarFill = PdfColor.fromHex('#FFD60A');

  static pw.Widget build(
    ResumeModel resume,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontItalic,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 210,
          padding: pw.EdgeInsets.fromLTRB(20, 36, 18, 32),
          decoration: pw.BoxDecoration(color: _sidebarBg),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Container(
                  width: 80,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: PdfColor.fromHex('#444444'),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      _getInitials(resume.personalInfo.fullName),
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 26,
                        color: _accent,
                      ),
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 24),

              if (resume.summary.isNotEmpty) ...[
                _sidebarHeader('ABOUT ME', fontBold),
                pw.SizedBox(height: 10),
                pw.Text(
                  resume.summary,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    color: PdfColor.fromHex('#CCCCCC'),
                    lineSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 24),
              ],

              if (resume.skills.isNotEmpty) ...[
                _sidebarHeader('SKILLS', fontBold),
                pw.SizedBox(height: 10),
                ...resume.skills.asMap().entries.map((entry) {
                  final index = entry.key;
                  final skill = entry.value;
                  final proficiency = (0.5 + (index % 5) * 0.1).clamp(0.5, 1.0);
                  return pw.Padding(
                    padding: pw.EdgeInsets.only(bottom: 8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          skill,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9,
                            color: PdfColor.fromHex('#CCCCCC'),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          height: 4,
                          child: pw.Row(
                            children: [
                              pw.Expanded(
                                flex: (proficiency * 100).toInt(),
                                child: pw.Container(
                                  decoration: pw.BoxDecoration(
                                    color: _skillBarFill,
                                    borderRadius: pw.BorderRadius.all(
                                      pw.Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: ((1 - proficiency) * 100).toInt(),
                                child: pw.Container(
                                  decoration: pw.BoxDecoration(
                                    color: _skillBarBg,
                                    borderRadius: pw.BorderRadius.all(
                                      pw.Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),

        pw.Expanded(
          child: pw.Padding(
            padding: pw.EdgeInsets.fromLTRB(32, 36, 36, 32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  resume.personalInfo.fullName.toUpperCase(),
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 26,
                    color: _textDark,
                    letterSpacing: 2,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: 180,
                  height: 6,
                  decoration: pw.BoxDecoration(color: _accent),
                ),
                pw.SizedBox(height: 16),

                pw.Center(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (resume.personalInfo.address != null &&
                          resume.personalInfo.address!.isNotEmpty)
                        pw.Text(
                          resume.personalInfo.address!,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9,
                            color: _textGray,
                          ),
                        ),
                      pw.SizedBox(height: 3),
                      if (resume.personalInfo.phoneNumber.isNotEmpty)
                        pw.Text(
                          'phone: ${resume.personalInfo.phoneNumber}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9,
                            color: _textGray,
                          ),
                        ),
                      pw.SizedBox(height: 3),
                      if (resume.personalInfo.email.isNotEmpty)
                        pw.Text(
                          'email: ${resume.personalInfo.email}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9,
                            color: _textGray,
                          ),
                        ),
                      if (resume.personalInfo.linkedIn != null &&
                          resume.personalInfo.linkedIn!.isNotEmpty) ...[
                        pw.SizedBox(height: 3),
                        pw.Text(
                          resume.personalInfo.linkedIn!,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9,
                            color: _textGray,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 28),

                if (resume.experience.isNotEmpty) ...[
                  _mainSectionHeader('EXPERIENCE', fontBold),
                  pw.SizedBox(height: 12),
                  ...resume.experience.map((exp) {
                    final dateRange = _formatDateRange(
                      exp.startDate,
                      exp.endDate,
                      exp.isCurrent,
                    );
                    return pw.Padding(
                      padding: pw.EdgeInsets.only(bottom: 14),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '${exp.position.toUpperCase()} ($dateRange)',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: _textDark,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          if (exp.company.isNotEmpty)
                            pw.Text(
                              exp.company,
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 9,
                                color: _textGray,
                              ),
                            ),
                          if (exp.responsibilities.isNotEmpty) ...[
                            pw.SizedBox(height: 6),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: exp.responsibilities.map((resp) {
                                return pw.Padding(
                                  padding: pw.EdgeInsets.only(bottom: 3),
                                  child: pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Container(
                                        margin: pw.EdgeInsets.only(top: 3),
                                        width: 3,
                                        height: 3,
                                        decoration: pw.BoxDecoration(
                                          shape: pw.BoxShape.circle,
                                          color: _accent,
                                        ),
                                      ),
                                      pw.SizedBox(width: 8),
                                      pw.Expanded(
                                        child: pw.Text(
                                          resp,
                                          style: pw.TextStyle(
                                            font: font,
                                            fontSize: 9,
                                            color: _textGray,
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
                      ),
                    );
                  }),
                  pw.SizedBox(height: 8),
                ],

                if (resume.education.isNotEmpty) ...[
                  _mainSectionHeader('EDUCATION', fontBold),
                  pw.SizedBox(height: 12),
                  ...resume.education.map((edu) {
                    final gradYear = _dateFormatter.format(edu.graduationDate);
                    final degreeText = '${edu.degree} in ${edu.major}';
                    return pw.Padding(
                      padding: pw.EdgeInsets.only(bottom: 12),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '${edu.school.toUpperCase()} ($gradYear)',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: _textDark,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            degreeText,
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 9,
                              color: _textGray,
                            ),
                          ),
                          if (edu.gpa != null) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'GPA: ${edu.gpa!.toStringAsFixed(1)}',
                              style: pw.TextStyle(
                                font: fontItalic,
                                fontSize: 8,
                                color: _textLightGray,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],

                if (resume.projects.isNotEmpty) ...[
                  _mainSectionHeader('PROJECTS', fontBold),
                  pw.SizedBox(height: 12),
                  ...resume.projects.map((proj) {
                    return pw.Padding(
                      padding: pw.EdgeInsets.only(bottom: 10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            proj.name.toUpperCase(),
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: _textDark,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            proj.description,
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 9,
                              color: _textGray,
                              lineSpacing: 1.3,
                            ),
                          ),
                          if (proj.technologies.isNotEmpty) ...[
                            pw.SizedBox(height: 6),
                            pw.Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: proj.technologies.map((tech) {
                                return pw.Container(
                                  padding: pw.EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColor.fromHex('#F5F5F5'),
                                    borderRadius: pw.BorderRadius.circular(10),
                                  ),
                                  child: pw.Text(
                                    tech,
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 7,
                                      color: _textGray,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],

                if (resume.certificates.isNotEmpty) ...[
                  _mainSectionHeader('CERTIFICATIONS', fontBold),
                  pw.SizedBox(height: 12),
                  ...resume.certificates.map((cert) {
                    final dateStr = _dateFormatter.format(cert.date);
                    return pw.Padding(
                      padding: pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  cert.name,
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 9,
                                    color: _textDark,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  cert.organization,
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 8,
                                    color: _textGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Text(
                            dateStr,
                            style: pw.TextStyle(
                              font: fontItalic,
                              fontSize: 8,
                              color: _textLightGray,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  static String _formatDateRange(
    DateTime start,
    DateTime? end,
    bool isCurrent,
  ) {
    final startStr = _dateFormatter.format(start);
    if (isCurrent) return '$startStr - NOW';
    if (end == null) return startStr;
    final endStr = _dateFormatter.format(end);
    return '$startStr - $endStr';
  }

  static pw.Widget _sidebarHeader(String title, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromHex('#555555'), width: 1),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 12,
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  static pw.Widget _mainSectionHeader(String title, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.only(bottom: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _divider, width: 1),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 14,
          color: _textDark,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
    );
  }
}
