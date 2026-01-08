import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class HistoryItem {
  final String fileName;
  final String fullPath;
  final DateTime dateSaved;

  HistoryItem({
    required this.fileName,
    required this.fullPath,
    required this.dateSaved,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'fullPath': fullPath,
        'dateSaved': dateSaved.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        fileName: json['fileName'],
        fullPath: json['fullPath'],
        dateSaved: DateTime.parse(json['dateSaved']),
      );
}

class ConversionStorage {
  static final _historyFile = File('conversion_history.json');


  static Future<File> saveFile({
    required String fullPath,
    required List<int> bytes,
  }) async {
    final file = File(fullPath);
    await file.writeAsBytes(bytes);

    await addToHistory(fullPath);

    return file;
  }

  static Future<void> delete(HistoryItem item) async {
    final file = File(item.fullPath);
    if (await file.exists()) await file.delete();

    final history = await getHistory();
    history.removeWhere((h) => h.fullPath == item.fullPath);
    await _saveHistory(history);
  }

  static Future<List<HistoryItem>> getHistory() async {
    if (!await _historyFile.exists()) return [];
    final content = await _historyFile.readAsString();
    return (jsonDecode(content) as List)
        .map((e) => HistoryItem.fromJson(e))
        .toList();
  }

  static Future<void> addToHistory(String fullPath) async {
    final history = await getHistory();
    final fileName = p.basename(fullPath);

    history.add(HistoryItem(
      fileName: fileName,
      fullPath: fullPath,
      dateSaved: DateTime.now(),
    ));

    await _saveHistory(history);
  }

  static Future<void> _saveHistory(List<HistoryItem> history) async {
    await _historyFile.writeAsString(
      jsonEncode(history.map((h) => h.toJson()).toList()),
    );
  }

  
  static Future<void> openFolder(String filePath) async {
    final dirPath = p.dirname(filePath);
    if (Platform.isWindows) {
      await Process.start('explorer', [dirPath]);
    }
  }
}
