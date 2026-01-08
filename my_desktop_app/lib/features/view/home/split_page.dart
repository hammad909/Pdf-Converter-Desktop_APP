import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_desktop_app/features/convert/data/history_item.dart';
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
      context,
      MaterialPageRoute(
        builder: (_) => SplitPagesPreviewPage(splitPages: pages),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Split PDF', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Select a PDF to split into pages', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 24),
        
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: pickPdf,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 220,
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedPdf != null ? Colors.green : theme.dividerColor,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: selectedPdf != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    selectedPdf!.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.upload_file, size: 48, color: theme.dividerColor),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Click to select a file',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: 220,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: selectedPdf == null || isSplitting ? null : splitPdf,
                      icon: const Icon(Icons.call_split),
                      label: isSplitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Split PDF'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 24),

              if (selectedPdf != null)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SfPdfViewer.file(
                        File(selectedPdf!.path!),
                        canShowScrollHead: false,
                        canShowScrollStatus: false,
                      ),
                    ),
                  ),
                ),
            ],
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

  late final ScrollController _gridScrollController;

@override
void initState() {
  super.initState();
  pageGroupColors = List<Color?>.filled(widget.splitPages.length, null);
  _gridScrollController = ScrollController();
}

@override
void dispose() {
  _gridScrollController.dispose();
  super.dispose();
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
    for (final entry in groups.entries) {
      final files = entry.value;
      if (files.isEmpty) continue;

      String defaultName = files.length > 1 ? 'merged_group.pdf' : path.basename(files.first.path);
      String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Grouped PDF',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (savePath == null) continue;

      if (!savePath.toLowerCase().endsWith('.pdf')) {
        savePath += '.pdf';
      }

      if (files.length == 1) {
        final bytes = await files.first.readAsBytes();
        await ConversionStorage.saveFile(fullPath: savePath, bytes: bytes);
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempPath = path.join(tempDir.path, 'temp_merged.pdf');

        await PdfMergeService.mergePdfs(
          inputFiles: files,
          outputPath: tempPath,
        );

        final bytes = await File(tempPath).readAsBytes();
        await ConversionStorage.saveFile(fullPath: savePath, bytes: bytes);
      }
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
    if (mounted) Navigator.pop(context);
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
  child: ScrollConfiguration(
    behavior:  ScrollConfiguration.of(context).copyWith(
      scrollbars: false,
    ),
    child: Scrollbar(
      controller: _gridScrollController,
      thumbVisibility: true,
      thickness: 6,
      radius: const Radius.circular(8),
      interactive: true,
      child: GridView.builder(
        controller: _gridScrollController,
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



