import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_desktop_app/features/convert/models/conversion_option.dart';


class ConversionState {
  final ConversionOption? selectedOption;
  final File? selectedFile;

  const ConversionState({
    this.selectedOption,
    this.selectedFile,
  });

  ConversionState copyWith({
    ConversionOption? selectedOption,
    File? selectedFile,
  }) {
    return ConversionState(
      selectedOption: selectedOption ?? this.selectedOption,
      selectedFile: selectedFile ?? this.selectedFile,
    );
  }
}

class ConversionNotifier extends StateNotifier<ConversionState> {
  ConversionNotifier() : super(const ConversionState());

  void selectOption(ConversionOption option) {
    state = state.copyWith(selectedOption: option);
  }

  void selectFile(File file) {
    state = state.copyWith(selectedFile: file);
  }

  void reset() {
    state = const ConversionState();
  }
}

final conversionProvider =
    StateNotifierProvider<ConversionNotifier, ConversionState>(
  (ref) => ConversionNotifier(),
);
