import 'dart:io';
import 'package:docx_viewer/docx_viewer.dart';
import 'package:flutter/material.dart';
import 'package:my_desktop_app/features/convert/data/pdf_viewer.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:open_filex/open_filex.dart';

class DocumentPreview extends StatelessWidget {
  final File file;
  final double height;
  final double maxWidth;
  final String? label;

  const DocumentPreview({
    super.key,
    required this.file,
    this.height = 600,
    this.maxWidth = 400,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final ext = p.extension(file.path).toLowerCase();

    // 1. Keep your PDF Logic
    if (ext == '.pdf') {
      return SimplePdfPreview(
        pdfFile: file,
        height: height,
        maxWidth: maxWidth,
        label: label,
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: SizedBox(
        width: maxWidth,
        height: height,
        child: Column(
          children: [
            _buildHeader(ext),
            const Divider(height: 1),
            Expanded(
              child: _buildContentPreview(ext),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPreview(String ext) {
  if (ext == '.docx') {
    return DocxView(
      filePath: file.path,
      fontSize: 14,
      onError: (error) => _buildSystemOpenPlaceholder(ext),
    );
  }

  if (['.pptx', '.rtf', '.xlsx'].contains(ext)) {
    return _buildSystemOpenPlaceholder(ext);
  }

  return FutureBuilder<String>(
    future: file.readAsString(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return const Center(child: Text("Unable to preview this file type"));
      }

      final content = snapshot.data ?? "";

      if (ext == '.html' || ext == '.htm') {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: HtmlWidget(content),
        );
      }

      return Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            content,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      );
    },
  );
}


  Widget _buildSystemOpenPlaceholder(String ext) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          ext == '.pptx' ? Icons.slideshow : Icons.description,
          size: 64,
          color: Colors.blueGrey.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        const Text(
          "Preview not available for this format",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => OpenFilex.open(file.path),
          icon: const Icon(Icons.open_in_new),
          label: const Text("Open in System"),
        ),
      ],
    );
  }

  Widget _buildHeader(String ext) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(_getIconForExt(ext), color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label ?? p.basename(file.path),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForExt(String ext) {
    if (ext == '.docx' || ext == '.rtf') return Icons.description;
    if (ext == '.pptx') return Icons.slideshow;
    if (ext == '.html' || ext == '.htm') return Icons.code;
    return Icons.article;
  }
}