import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfMergeService {
  static Future<File> mergePdfs({
    required List<File> inputFiles,
    required String outputPath,
  }) async {
    if (inputFiles.length < 2) {
      throw Exception('Select at least 2 PDF files to merge.');
    }

    final PdfDocument newDocument = PdfDocument();
    PdfSection? section;

    for (final file in inputFiles) {
      final bytes = await file.readAsBytes();
      final PdfDocument loadedDocument = PdfDocument(inputBytes: bytes);

      for (int i = 0; i < loadedDocument.pages.count; i++) {
        final PdfTemplate template = loadedDocument.pages[i].createTemplate();
        
        if (section == null || section.pageSettings.size != template.size) {
          section = newDocument.sections!.add();
          section.pageSettings.size = template.size;
          section.pageSettings.margins.all = 0;
        }

        section.pages
            .add()
            .graphics
            .drawPdfTemplate(template, const Offset(0, 0));
      }

      loadedDocument.dispose();
    }

    final List<int> mergedBytes = await newDocument.save();
    newDocument.dispose();

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(mergedBytes, flush: true);
    return outputFile;
  }
}
