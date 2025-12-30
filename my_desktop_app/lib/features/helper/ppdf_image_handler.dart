import 'dart:io';
import 'dart:ui';
import 'package:pdf_render/pdf_render.dart';


Future<Image> pdfPageToUiImage(File pdfFile, {int targetWidth = 1080}) async {
  final doc = await PdfDocument.openFile(pdfFile.path);

  final page = await doc.getPage(1);

  final width = targetWidth;
  final height = (width * page.height / page.width).round();

  final pageImage = await page.render(
    width: width,
    height: height,
  );
  
  await pageImage.createImageIfNotAvailable();
  return pageImage.imageIfAvailable!;
}
