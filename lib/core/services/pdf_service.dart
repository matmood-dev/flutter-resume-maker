import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/resume_model.dart';
import 'templates/modern_template.dart';
import 'templates/ats_template.dart';

class PdfService {
  static Future<Uint8List> generateResumePdf(
    ResumeModel resume, {
    String templateName = 'modern',
  }) async {
    final doc = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final fontItalic = pw.Font.helveticaOblique();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => [
          templateName == 'ats'
              ? AtsTemplate.build(resume, font, fontBold, fontItalic)
              : ModernTemplate.build(resume, font, fontBold, fontItalic),
        ],
      ),
    );

    return doc.save();
  }
}
