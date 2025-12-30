// ignore: file_names
import 'dart:io';
import 'package:dio/dio.dart';

class ConversionService {
  final Uri serverUri;
  final Dio _dio = Dio();

  ConversionService({required this.serverUri});

  Future<String> uploadFileForConversion({
    required File inputFile,
    required String endpoint,
    void Function(double progress)? onProgress,
  }) async {
    final uploadUri = serverUri.replace(path: endpoint);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        inputFile.path,
        filename: inputFile.path.split(Platform.pathSeparator).last,
      ),
    });

    final response = await _dio.postUri(
      uploadUri,
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0 && onProgress != null) onProgress(sent / total);
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Conversion failed: ${response.data}');
    }

    return response.data['file']; 
  }

  Future<List<int>> downloadConvertedFileBytes(String fileName) async {
    final downloadUrl = serverUri.replace(path: '/download/$fileName').toString();
    final response = await _dio.get<List<int>>(
      downloadUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Failed to download converted file.');
    }

    return response.data!;
  }
}
