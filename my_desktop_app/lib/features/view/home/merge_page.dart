import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_desktop_app/features/convert/service/file_picker_service.dart';
import 'package:my_desktop_app/features/convert/service/merge_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


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
        right: MediaQuery.of(context).size.width * 0.15,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
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
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

Future<void> mergeAndSave() async {
  if (selectedFiles.length < 2) return;

  setState(() {
    isMerging = true;
    mergedFile = null;
  });

  final documentsDir = await getApplicationDocumentsDirectory();

  final outputDir = Directory(
    path.join(documentsDir.path, 'Converted Files'),
  );

  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  String getNextFileName() {
    int counter = 1;
    String filePath;
    do {
      filePath = path.join(outputDir.path, 'merged_$counter.pdf');
      counter++;
    } while (File(filePath).existsSync());
    return filePath;
  }

  final outputPath = getNextFileName();
  final startTime = DateTime.now();

  try {
    await PdfMergeService.mergePdfs(
      inputFiles: selectedFiles,
      outputPath: outputPath,
    );

    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inSeconds < 4) {
      await Future.delayed(
        Duration(seconds: 4 - elapsed.inSeconds),
      );
    }

    final file = File(outputPath);
    if (mounted) {
      setState(() => mergedFile = file);
      showTopNotification('PDFs merged successfully!');
    }
  } catch (e) {
    showTopNotification(
      'Merge failed: ${e.toString()}',
      color: Colors.red,
    );
  } finally {
    if (mounted) setState(() => isMerging = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: isMerging ? null : pickFiles,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 420,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.05),
                  border: Border.all(
                    color: mergedFile != null
                        ? Colors.green
                        : Colors.blueGrey,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      mergedFile != null
                          ? Icons.check_circle
                          : Icons.insert_drive_file,
                      size: 48,
                      color: mergedFile != null
                          ? Colors.green
                          : Colors.blueGrey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      selectedFiles.isEmpty
                          ? 'Click to select PDF files'
                          : '${selectedFiles.length} file(s) selected',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (selectedFiles.isNotEmpty)
            SizedBox(
              width: 520,
              height: 200,
              child: GridView.builder(
                itemCount: selectedFiles.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3,
                ),
                itemBuilder: (context, index) {
                  final file = selectedFiles[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            size: 18, color: Colors.red),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            file.path.split(Platform.pathSeparator).last,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        GestureDetector(
                          onTap: isMerging ? null : () => removeFile(index),
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed:
                selectedFiles.length < 2 || isMerging ? null : mergeAndSave,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: isMerging
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Merge & Save'),
            ),
          ),

          if (mergedFile != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Merge completed successfully',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
