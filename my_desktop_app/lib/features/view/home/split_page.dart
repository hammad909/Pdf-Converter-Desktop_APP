import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_desktop_app/features/convert/service/merge_service.dart';
import 'package:my_desktop_app/features/convert/service/split_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SplitDetails extends StatefulWidget {
  const SplitDetails({super.key});

  @override
  State<SplitDetails> createState() => _SplitMainPageState();
}

class _SplitMainPageState extends State<SplitDetails> {
  PlatformFile? selectedPdf;
  bool isSplitting = false;

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        selectedPdf = result.files.first;
      });
    }
  }

  Future<void> splitPdf() async {
    if (selectedPdf == null) return;

    setState(() {
      isSplitting = true;
    });

    final file = File(selectedPdf!.path!);
    final pages = await SplitService.splitPdfPageByPage(inputFile: file);

    setState(() {
      isSplitting = false;
    });

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (_) => SplitPagesPreviewPage(splitPages: pages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
  color: theme.cardTheme.color,
  borderRadius: BorderRadius.circular(16),
  boxShadow: const [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ],
  border: Border.all(
    color: selectedPdf != null
        ? theme.colorScheme.primary
        // ignore: deprecated_member_use
        : theme.colorScheme.onSurface.withOpacity(0.3),
    width: 1.5,
  ),
),

              width: 300,
              height: 180,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: pickPdf,
                child: Center(
                  child: selectedPdf != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              selectedPdf!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 48,
                              color:
                                  // ignore: deprecated_member_use
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Click to select PDF',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16), 

          SizedBox(
            width: 180,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: selectedPdf == null || isSplitting ? null : splitPdf,
              icon: const Icon(Icons.call_split),
              label: isSplitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Split PDF'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




class SplitPagesPreviewPage extends StatefulWidget {
  final List<File> splitPages;

  const SplitPagesPreviewPage({super.key, required this.splitPages});

  @override
  State<SplitPagesPreviewPage> createState() => _SplitPagesPreviewPageState();
}

class _SplitPagesPreviewPageState extends State<SplitPagesPreviewPage> {
  Color? selectedColor;
  late List<Color?> pageGroupColors;

  final List<Color> groupColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    pageGroupColors = List<Color?>.filled(widget.splitPages.length, null);
  }

  void assignColorToPage(int index) {
    if (selectedColor == null) return;
    setState(() {
      pageGroupColors[index] = selectedColor;
    });
  }

  void removeColorFromPage(int index) {
    setState(() {
      pageGroupColors[index] = null;
    });
  }

  bool hasSelectedPages() {
    return pageGroupColors.any((color) => color != null);
  }

Future<void> saveGroupedPages() async {
  if (!hasSelectedPages()) return;

  final Map<Color, List<File>> groups = {};

  for (int i = 0; i < widget.splitPages.length; i++) {
    final color = pageGroupColors[i];
    if (color == null) continue;

    groups.putIfAbsent(color, () => []).add(widget.splitPages[i]);
  }

  if (groups.isEmpty) return;

  try {

    final documentsDir = await getApplicationDocumentsDirectory();

    final outputDir = Directory(
      path.join(documentsDir.path, 'Converted Files'),
    );

    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    int groupIndex = 1;

    while (File(path.join(outputDir.path, 'group_$groupIndex.pdf')).existsSync()) {
      groupIndex++;
    }

    for (final entry in groups.entries) {
      final files = entry.value;
      if (files.isEmpty) continue;

      final outputPath = path.join(
        outputDir.path,
        'group_$groupIndex.pdf',
      );

      if (files.length == 1) {
        await files.first.copy(outputPath);
      } else {
        await PdfMergeService.mergePdfs(
          inputFiles: files,
          outputPath: outputPath,
        );
      }

      groupIndex++;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grouped PDFs saved successfully!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to save groups: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Split Pages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Pick a color to assign pages:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: groupColors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final color = groupColors[index];
                final isSelected = selectedColor == color;

                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Pages (${widget.splitPages.length}):',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: widget.splitPages.length,
              itemBuilder: (context, index) {
                final pageColor = pageGroupColors[index];

                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: pageColor ?? Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SfPdfViewer.file(
                          widget.splitPages[index],
                          canShowScrollHead: false,
                          canShowScrollStatus: false,
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => assignColorToPage(index),
                        ),
                      ),
                    ),
                    if (pageColor != null)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: GestureDetector(
                          onTap: () => removeColorFromPage(index),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: pageColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: hasSelectedPages() ? saveGroupedPages : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Grouped PDFs'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



