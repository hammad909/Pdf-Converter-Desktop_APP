import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_desktop_app/features/convert/data/history_item.dart';
import 'package:my_desktop_app/features/convert/service/file_picker_service.dart';
import 'package:my_desktop_app/features/convert/service/merge_service.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:reorderables/reorderables.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class MergeDetails extends StatefulWidget {
  const MergeDetails({super.key});

  @override
  State<MergeDetails> createState() => _MergeDetailsState();
}

class _MergeDetailsState extends State<MergeDetails> {
  List<File> selectedFiles = [];
  bool isMerging = false;
  File? mergedFile;

  Future<void> pickFiles() async {
    final files = await FilePickerService.pickMultipleFiles(['pdf']);
    if (files.isNotEmpty) {
      setState(() {
        selectedFiles = files;
        mergedFile = null;
      });
    }
  }

  void removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
      mergedFile = null;
    });
  }

  void showTopNotification(String message, {Color color = Colors.green}) {
    if (!mounted) return;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: kToolbarHeight + 16,
        left: MediaQuery.of(context).size.width * 0.25,
        right: MediaQuery.of(context).size.width * 0.25,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.95),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  color == Colors.red ? Icons.error : Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), overlayEntry.remove);
  }

  Future<void> mergeAndSave() async {
    if (selectedFiles.length < 2) return;

    setState(() => isMerging = true);

    try {
      String? savePath = await FilePickerService.pickSaveFile(
        dialogTitle: 'Save Merged PDF',
        fileName: 'merged.pdf',
        allowedExtensions: ['pdf'],
      );

      if (savePath == null) {
        setState(() => isMerging = false);
        return;
      }

      if (!savePath.toLowerCase().endsWith('.pdf')) {
        savePath += '.pdf';
      }

      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(tempDir.path, 'temp_merged.pdf');

      await PdfMergeService.mergePdfs(
        inputFiles: selectedFiles,
        outputPath: tempPath,
      );

      final bytes = await File(tempPath).readAsBytes();
      final file = await ConversionStorage.saveFile(
        fullPath: savePath,
        bytes: bytes,
      );

      setState(() => mergedFile = file);

      showTopNotification('PDFs merged successfully!');
    } catch (e) {
      showTopNotification('Merge failed: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => isMerging = false);
    }
  }



@override
Widget build(BuildContext context) {
  return ClipRect(
  child: Padding(
    padding: const EdgeInsets.all(32),
    child: LayoutBuilder(
      builder: (context, constraints) {
      const gap = 32.0;

final usableWidth = constraints.maxWidth - gap;
final leftWidth = usableWidth * 0.28;
final rightWidth = usableWidth * 0.72;


        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            SizedBox(
              width: leftWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Merge PDFs',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pick at least two PDF files to merge',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: isMerging ? null : pickFiles,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blueGrey),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(
                            selectedFiles.isEmpty
                                ? 'Click to select PDF files'
                                : '${selectedFiles.length} file(s) selected',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (selectedFiles.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            const Text(
                              'Drag files to reorder',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          selectedFiles.length < 2 || isMerging ? null : mergeAndSave,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: isMerging
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Merge & Save'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 32),

SizedBox(
  width: rightWidth,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Merge Order',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 12),

Expanded(
  child: selectedFiles.isEmpty
      ? const Center(
          child: Text(
            'Selected files will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        )
      : LayoutBuilder(
          builder: (context, constraints) {
            const double spacing = 12;
int columns;

if (constraints.maxWidth > 900) {
  columns = 4;
} else if (constraints.maxWidth > 650) {
  columns = 3;
} else if (constraints.maxWidth > 420) {
  columns = 2;
} else {
  columns = 1;
}


            final totalSpacing = (columns - 1) * spacing;
            final usableWidth = constraints.maxWidth - totalSpacing;

const double outerPadding = 16; 

final double cardWidth =
    (usableWidth - outerPadding * 2) / columns;




         return ClipRect(
  child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade900.withOpacity(0.35),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade800),
    ),
    child: SizedBox(
      height: constraints.maxHeight,
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ReorderableWrap(
        spacing: spacing,
        runSpacing: spacing,
        needsLongPressDraggable: false,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            final file = selectedFiles.removeAt(oldIndex);
            selectedFiles.insert(newIndex, file);
          });
        },
children: List.generate(selectedFiles.length, (index) {
  final file = selectedFiles[index];
  final fileName = path.basename(file.path);

  return GestureDetector(
    key: ValueKey(file.path),
    onTap: () {
      if (!isMerging) OpenFile.open(file.path);
    },
    child: Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 2),
            color: Colors.black26,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.white70),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: isMerging ? null : () => removeFile(index),
              ),
            ],
          ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SfPdfViewer.file(
                file,
                scrollDirection: PdfScrollDirection.vertical,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}),






      ),
    ),
    ),
  ),
);

          },
        ),
),

    ],
  ),
),




          ],
        );
      },
    ),
  ),
  );

}




}

