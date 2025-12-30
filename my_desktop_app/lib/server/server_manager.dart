import 'dart:io';
import 'package:flutter/services.dart';

class ServerManager {
  static const String serverExeAsset = 'assets/server/PdfConversionServer.exe';
  static const String serverExeName = 'PdfConversionServer.exe';
  static const String portFileName = 'pdf_converter_port.txt';
  static Process? _serverProcess;


  static Future<Directory> _getServerFolder() async {
    final localAppData = Platform.environment['LOCALAPPDATA']!;
    final serverDir = Directory('$localAppData\\PdfConverterFiles');
    if (!await serverDir.exists()) {
      await serverDir.create(recursive: true);
    }

    final uploadsDir = Directory('${serverDir.path}\\uploads');
    final convertedDir = Directory('${serverDir.path}\\converted');
    if (!await uploadsDir.exists()) await uploadsDir.create();
    if (!await convertedDir.exists()) await convertedDir.create();

    return serverDir;
  }

  static Future<File> _prepareServerExe() async {
    final serverDir = await _getServerFolder();
    final exeFile = File('${serverDir.path}\\$serverExeName');

    if (!await exeFile.exists()) {
      final byteData = await rootBundle.load(serverExeAsset);
      await exeFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    }
    return exeFile;
  }
static Future<void> startServer() async {
  if (_serverProcess != null) return;

  final serverDir = await _getServerFolder();

  final portFile = File('${serverDir.path}\\$portFileName');
  if (await portFile.exists()) await portFile.delete();


  await killExistingServer();

  final exe = await _prepareServerExe();

  _serverProcess = await Process.start(
    exe.path,
    [],
    workingDirectory: serverDir.path,
    mode: ProcessStartMode.normal,
    runInShell: true,
  );
}


  static Future<int> readServerPort() async {
    final serverDir = await _getServerFolder();
    final portFile = File('${serverDir.path}\\$portFileName');

    for (int i = 0; i < 60; i++) {
      if (await portFile.exists()) {
        final content = (await portFile.readAsString()).trim();
        if (content.isNotEmpty) return int.parse(content);
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    throw Exception('Server port file not found');
  }


  static Future<Uri> startAndGetServerUri() async {
    await startServer();
    final port = await readServerPort();
    return Uri.parse('http://127.0.0.1:$port');
  }

 static Future<void> stopServer() async {

  if (_serverProcess != null) {
    try {
      _serverProcess!.kill(ProcessSignal.sigkill);
    } catch (_) {}
    _serverProcess = null;
  }
  try {
    final serverDir = await _getServerFolder();
    final portFile = File('${serverDir.path}\\$portFileName');
    if (await portFile.exists()) {
      await portFile.delete();
    }
  } catch (_) {
   
  }
}

static Future<void> killExistingServer() async {
  try {
    if (Platform.isWindows) {
      final result = await Process.run(
        'tasklist',
        [],
        runInShell: true,
      );
      if (result.stdout.toString().contains(serverExeName)) {
        await Process.run(
          'taskkill',
          ['/F', '/IM', serverExeName],
          runInShell: true,
        );
      }
    }
  } catch (_) {}
}


}
