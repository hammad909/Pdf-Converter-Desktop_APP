import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_desktop_app/features/convert/data/conversion_Service.dart';
import 'package:my_desktop_app/features/convert/data/conversion_options.dart';
import 'package:my_desktop_app/features/convert/data/document_preview.dart';
import 'package:my_desktop_app/features/convert/data/history_item.dart';
import 'package:my_desktop_app/features/convert/models/conversion_option.dart';
import 'package:my_desktop_app/features/view/widgets/conversion_card.dart';
import 'package:my_desktop_app/features/view/widgets/section_header.dart';
import 'package:my_desktop_app/server/server_manager.dart';
import 'package:path/path.dart' as p;


final serverUriProvider = FutureProvider<Uri>((ref) async {
  return ServerManager.startAndGetServerUri();
});

class ConvertPage extends ConsumerStatefulWidget {
  const ConvertPage({super.key});

  @override
  ConsumerState<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends ConsumerState<ConvertPage> {
  final ScrollController _scrollController = ScrollController();
  ConversionOption? selectedOption;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void openDetail(ConversionOption option) {
    setState(() => selectedOption = option);
  }

  void goBack() {
    setState(() => selectedOption = null);
  }

  @override
  Widget build(BuildContext context) {
    final serverUriAsync = ref.watch(serverUriProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: serverUriAsync.when(
        data: (serverUri) {
          return selectedOption == null
              ? _buildGridView()
              : ConvertDetailPage(
                  option: selectedOption!,
                  serverUri: serverUri,
                  onBack: goBack,
                );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Failed to start server:\n$err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Conversion Type',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'PDF to Other Formats'),
                  _ConversionGrid(
                    options: pdfToOthers,
                    onTap: openDetail,
                  ),
                  const SizedBox(height: 32),
                  const SectionHeader(title: 'Other Formats to PDF'),
                  _ConversionGrid(
                    options: othersToPdf,
                    onTap: openDetail,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConversionGrid extends StatelessWidget {
  final List<ConversionOption> options;
  final void Function(ConversionOption) onTap;

  const _ConversionGrid({
    required this.options,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: options.length,
      itemBuilder: (_, index) {
        return ConversionCard(
          option: options[index],
          onTap: () => onTap(options[index]),
        );
      },
    );
  }
}

class ConvertDetailPage extends StatefulWidget {
  final ConversionOption option;
  final Uri serverUri;
  final VoidCallback onBack;

  const ConvertDetailPage({
    super.key,
    required this.option,
    required this.serverUri,
    required this.onBack,
  });

  @override
  State<ConvertDetailPage> createState() => _ConvertDetailPageState();
}

class _ConvertDetailPageState extends State<ConvertDetailPage> {
  File? selectedFile;
  String? convertedFileName; 
  File? savedFile;          

Timer? _conversionTimer;

  bool isLoading = false;
  double progress = 0.0;
  String? errorMessage;
bool get isFileReady => convertedFileName != null && !isLoading;

void _startConversionProgress() {
  _conversionTimer?.cancel();

  _conversionTimer = Timer.periodic(
    const Duration(milliseconds: 300),
    (timer) {
      if (!mounted) return;

      setState(() {
        if (progress < 0.95) {
          progress += 0.01;
        }
      });
    },
  );
}

void _stopConversionProgress() {
  _conversionTimer?.cancel();
}

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.option.allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        convertedFileName = null;
        savedFile = null;
        errorMessage = null;
      });
    }
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
              const Icon(Icons.check_circle, color: Colors.white),
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



Future<void> uploadFile() async {
  if (selectedFile == null) return;

  setState(() {
    isLoading = true;
    progress = 0.0;
    errorMessage = null;
    convertedFileName = null;
    savedFile = null;
  });

  try {
    final service = ConversionService(serverUri: widget.serverUri);

    final fileName = await service.uploadFileForConversion(
      inputFile: selectedFile!,
      endpoint: widget.option.endpoint,
      onProgress: (value) {
        setState(() {
     
          progress = (value * 0.7).clamp(0.0, 0.7);
        });

        if (value >= 1.0) {
          _startConversionProgress();
        }
      },
    );

    _stopConversionProgress();

    setState(() {
      progress = 1.0; 
      convertedFileName = fileName;
    });
  } catch (e) {
    _stopConversionProgress();
    setState(() => errorMessage = _mapError(e));
  } finally {
    setState(() => isLoading = false);
  }
}

Future<void> convertAndSave() async {
  if (selectedFile == null) return;

  setState(() {
    isLoading = true;
    progress = 0.0;
    errorMessage = null;
    convertedFileName = null;
    savedFile = null;
  });

  try {
    final service = ConversionService(serverUri: widget.serverUri);

    final fileName = await service.uploadFileForConversion(
      inputFile: selectedFile!,
      endpoint: widget.option.endpoint,
      onProgress: (value) {
        setState(() {
          progress = (value * 0.7).clamp(0.0, 0.7);
        });

        if (value >= 1.0) _startConversionProgress();
      },
    );

    _stopConversionProgress();
    setState(() => progress = 1.0);
    convertedFileName = fileName;
    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Converted File',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: widget.option.allowedExtensions,
    );

    if (savePath == null) {
      setState(() => progress = 0.0);
      return;
    }

    final extension = p.extension(fileName);
    if (!savePath.toLowerCase().endsWith(extension.toLowerCase())) {
      savePath += extension;
    }

    final bytes = await service.downloadConvertedFileBytes(fileName);

    final file = await ConversionStorage.saveFile(
      fullPath: savePath,
      bytes: bytes,
    );

    setState(() => savedFile = file);

    showTopNotification('File saved successfully!');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File saved successfully!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    _stopConversionProgress();
    setState(() => errorMessage = _mapError(e));
  } finally {
    setState(() => isLoading = false);
  }
}


  String _mapError(dynamic e) {
    if (e is SocketException) {
      return 'Unable to connect to the conversion server.';
    } else if (e is TimeoutException) {
      return 'Conversion timed out. Please try again.';
    }
    return 'Conversion failed. Unsupported or corrupted file.';
  }
  
  @override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextButton.icon(
        onPressed: widget.onBack,
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back'),
      ),
      const SizedBox(height: 16),
      Text(widget.option.title,
          style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(widget.option.description),
      const SizedBox(height: 32),

Expanded(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 220,
              maxWidth: 260,
            ),
            child: InkWell(
              onTap: isLoading ? null : pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 1.4,
                    color: isFileReady
                        ? Colors.green
                        : selectedFile != null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                        ),
                      )
                    else
                      Icon(
                        selectedFile != null
                            ? Icons.check_circle
                            : Icons.upload_file,
                        size: 48,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      selectedFile == null
                          ? 'Click to select a file'
                          : p.basename(selectedFile!.path),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w500),
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
              onPressed:
                  selectedFile != null && !isLoading ? convertAndSave : null,
              icon: const Icon(Icons.upload_file),
              label: const Text('Convert & Save'),
            ),
          ),
        ],
      ),

      const SizedBox(width: 24),

if (selectedFile != null)
  Expanded(
    child: DocumentPreview(
      file: savedFile ?? selectedFile!, 
      maxWidth: double.infinity,
      height: double.infinity, 
    ),
  ),
    ],
  ),
),



      const SizedBox(height: 24),

      if (errorMessage != null)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(child: Text(errorMessage!)),
            ],
          ),
        ),

      if (savedFile != null) ...[
        const SizedBox(height: 24),
        Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Conversion completed successfully'),
          ],
        ),
      ],
    ],
  );
}
}