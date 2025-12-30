import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:my_desktop_app/features/convert/data/conversion_storage.dart';

enum FileFilter {
  all,
  rtf,
  pdf,
  docx,
  pptx,
  html,
  txt
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<File> allFiles = [];
  FileFilter selectedFilter = FileFilter.all;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final files = await ConversionStorage.getFiles();
    setState(() {
      allFiles = files;
    });
  }

  Future<void> _deleteFile(File file) async {
    await ConversionStorage.delete(file);
    await _loadFiles();
  }


  List<File> get filteredFiles {
    if (selectedFilter == FileFilter.all) return allFiles;

    return allFiles.where((file) {
      final ext = p.extension(file.path).toLowerCase();
      switch (selectedFilter) {
        case FileFilter.pdf:
          return ext == '.pdf';
           case FileFilter.rtf:
          return ext == '.rtf';
        case FileFilter.docx:
          return ext == '.docx';
        case FileFilter.pptx:
          return ext == '.pptx';
        case FileFilter.html:
          return ext == '.html';
          case FileFilter.txt:
          return ext == '.txt';
        default:
          return true;
      }
    }).toList();
  }

  Widget _filterButton(String label, FileFilter filter) {
    final isSelected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => selectedFilter = filter);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final files = filteredFiles;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterButton('All', FileFilter.all),
                _filterButton('TXT', FileFilter.txt),
                _filterButton('RTF', FileFilter.rtf),
                _filterButton('PDF', FileFilter.pdf),
                _filterButton('DOCX', FileFilter.docx),
                _filterButton('PPTX', FileFilter.pptx),
                _filterButton('HTML', FileFilter.html),
              ],
            ),
          ),
        ),

        const Divider(height: 1),

     
        Expanded(
          child: files.isEmpty
              ? Center(
                  child: Text(
                    'No converted files.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: files.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final fileName = p.basename(file.path);
                    final modified = file.lastModifiedSync();

                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(fileName),
                      subtitle:
                          Text('Modified: ${modified.toLocal()}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.folder_open),
                            onPressed: () {
                              OpenFilex.open(file.parent.path);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFile(file),
                          ),
                        ],
                      ),
                      onTap: () => OpenFilex.open(file.path),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
