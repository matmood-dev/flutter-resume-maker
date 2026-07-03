import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../../models/resume_model.dart';

class AtsTemplate {
  static final DateFormat _dateFormatter = DateFormat('yyyy');

  static pw.Widget build(
    ResumeModel resume,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontItalic,
  ) {
    final info = resume.personalInfo;

    return pw.Padding(
      padding: pw.EdgeInsets.fromLTRB(50, 40, 50, 40),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            info.fullName,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 22,
              color: PdfColors.black,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),

          pw.Text(
            _contactLine(info),
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColor.fromHex('#333333'),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColor.fromHex('#000000'), thickness: 1),
          pw.SizedBox(height: 12),

          if (resume.summary.isNotEmpty) ...[
            _sectionHeader('PROFESSIONAL SUMMARY', fontBold),
            pw.SizedBox(height: 6),
            pw.Text(
              resume.summary,
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColor.fromHex('#333333'),
                lineSpacing: 1.4,
              ),
            ),
            pw.SizedBox(height: 14),
          ],

          if (resume.experience.isNotEmpty) ...[
            _sectionHeader('EXPERIENCE', fontBold),
            pw.SizedBox(height: 6),
            ...resume.experience.map((exp) {
              final dateRange = _formatDateRange(
                exp.startDate,
                exp.endDate,
                exp.isCurrent,
              );
              return pw.Padding(
                padding: pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          exp.position,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 11,
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          dateRange,
                          style: pw.TextStyle(
                            font: fontItalic,
                            fontSize: 10,
                            color: PdfColor.fromHex('#555555'),
                          ),
                        ),
                      ],
                    ),
                    if (exp.company.isNotEmpty)
                      pw.Text(
                        exp.company,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColor.fromHex('#444444'),
                        ),
                      ),
                    if (exp.responsibilities.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: exp.responsibilities.map((resp) {
                          return pw.Padding(
                            padding: pw.EdgeInsets.only(bottom: 2),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  '• ',
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 10,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Text(
                                    resp,
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 10,
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
                ),
              );
            }),
          ],

          if (resume.education.isNotEmpty) ...[
            _sectionHeader('EDUCATION', fontBold),
            pw.SizedBox(height: 6),
            ...resume.education.map((edu) {
              final gradYear = _dateFormatter.format(edu.graduationDate);
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
                            edu.school,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 11,
                              color: PdfColors.black,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${edu.degree} in ${edu.major}',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 10,
                              color: PdfColor.fromHex('#444444'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Text(
                      gradYear,
                      style: pw.TextStyle(
                        font: fontItalic,
                        fontSize: 10,
                        color: PdfColor.fromHex('#555555'),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          if (resume.skills.isNotEmpty) ...[
            _sectionHeader('SKILLS', fontBold),
            pw.SizedBox(height: 6),
            pw.Text(
              resume.skills.join(' • '),
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColor.fromHex('#333333'),
              ),
            ),
            pw.SizedBox(height: 14),
          ],

          if (resume.projects.isNotEmpty) ...[
            _sectionHeader('PROJECTS', fontBold),
            pw.SizedBox(height: 6),
            ...resume.projects.map((proj) {
              return pw.Padding(
                padding: pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      proj.name,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 11,
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      proj.description,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        color: PdfColor.fromHex('#333333'),
                        lineSpacing: 1.3,
                      ),
                    ),
                    if (proj.technologies.isNotEmpty)
                      pw.Text(
                        'Technologies: ${proj.technologies.join(', ')}',
                        style: pw.TextStyle(
                          font: fontItalic,
                          fontSize: 9,
                          color: PdfColor.fromHex('#555555'),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],

          if (resume.certificates.isNotEmpty) ...[
            _sectionHeader('CERTIFICATIONS', fontBold),
            pw.SizedBox(height: 6),
            ...resume.certificates.map((cert) {
              final dateStr = _dateFormatter.format(cert.date);
              return pw.Padding(
                padding: pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '${cert.name} - ${cert.organization}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColor.fromHex('#333333'),
                        ),
                      ),
                    ),
                    pw.Text(
                      dateStr,
                      style: pw.TextStyle(
                        font: fontItalic,
                        fontSize: 10,
                        color: PdfColor.fromHex('#555555'),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  static String _contactLine(dynamic info) {
    final parts = <String>[];
    if (info.email.isNotEmpty) parts.add(info.email);
    if (info.phoneNumber.isNotEmpty) parts.add(info.phoneNumber);
    if (info.address != null && info.address!.isNotEmpty) parts.add(info.address!);
    if (info.linkedIn != null && info.linkedIn!.isNotEmpty) parts.add(info.linkedIn!);
    if (info.portfolioUrl != null && info.portfolioUrl!.isNotEmpty) {
      parts.add(info.portfolioUrl!);
    }
    return parts.join(' | ');
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

  static pw.Widget _sectionHeader(String title, pw.Font fontBold) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: fontBold,
        fontSize: 12,
        color: PdfColors.black,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}
