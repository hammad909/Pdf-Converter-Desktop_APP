import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class SplitService {
  static Future<List<File>> splitPdfPageByPage({required File inputFile}) async {
    final bytes = await inputFile.readAsBytes();
    final pdfDocument = PdfDocument(inputBytes: bytes);
    final tempDir = await getTemporaryDirectory();
    final List<File> pageFiles = [];

    for (int i = 0; i < pdfDocument.pages.count; i++) {
      final newDoc = PdfDocument();
      newDoc.pages.add().graphics.drawPdfTemplate(
        pdfDocument.pages[i].createTemplate(),
        Offset.zero,
        Size(pdfDocument.pages[i].size.width, pdfDocument.pages[i].size.height),
      );

      final file = File('${tempDir.path}/page_${i + 1}.pdf');
      await file.writeAsBytes(await newDoc.save());
      pageFiles.add(file);
      newDoc.dispose();
    }

    pdfDocument.dispose();
    return pageFiles;
  }
}
