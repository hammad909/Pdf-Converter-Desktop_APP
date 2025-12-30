import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ConversionStorage {
  static Future<Directory> _getConvertedFilesDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final convertedDir = Directory(p.join(baseDir.path, 'Converted Files'));
    if (!await convertedDir.exists()) await convertedDir.create(recursive: true);
    return convertedDir;
  }

  // Save bytes directly as a file
  static Future<File> saveFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    final dir = await _getConvertedFilesDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> delete(File file) async {
    if (await file.exists()) await file.delete();
  }

  static Future<void> openFolder() async {
    final dir = await _getConvertedFilesDirectory();
    if (Platform.isWindows) {
      Process.start('explorer', [dir.path]);
    }
  }

  static Future<List<File>> getFiles() async {
  final dir = await _getConvertedFilesDirectory();

  final files = dir
      .listSync()
      .whereType<File>()
      .toList()
    ..sort((a, b) {
      try {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      } catch (_) {
        return 0;
      }
    });

  return files;
}

}
