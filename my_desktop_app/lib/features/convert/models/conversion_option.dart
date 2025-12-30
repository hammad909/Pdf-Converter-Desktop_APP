import 'package:flutter/material.dart';

class ConversionOption {
  final String title;
  final String description;
  final IconData icon;
  final List<String> allowedExtensions;
  final String endpoint;
    final String outputExtension;

  const ConversionOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.allowedExtensions,
    required this.endpoint,
     required this.outputExtension,
  });
}
