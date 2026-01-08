import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart' as x;

class SimplePdfPreview extends StatelessWidget {
  final File pdfFile;
  final double height;
  final double maxWidth;
  final String? label;

  const SimplePdfPreview({
    super.key,
    required this.pdfFile,
    this.height = 600,
    this.maxWidth = 400, 
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: SizedBox(
        width: maxWidth,
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label ?? pdfFile.path.split(Platform.pathSeparator).last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: x.PdfViewer.file(
                    pdfFile.path,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
