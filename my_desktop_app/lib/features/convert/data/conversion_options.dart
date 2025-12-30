import 'package:flutter/material.dart';
import 'package:my_desktop_app/features/convert/models/conversion_option.dart';

const pdfToOthers = [
  ConversionOption(
    title: 'PDF to Word',
    description: 'Convert PDF documents to Word format',
    icon: Icons.description,
    allowedExtensions: ['pdf'],
    endpoint: '/upload/',
    outputExtension: 'docx',
  ),
  ConversionOption(
    title: 'PDF to RTF',
    description: 'Convert PDF documents to Rich Text format',
    icon: Icons.text_snippet,
    allowedExtensions: ['pdf'],
    endpoint: '/pdf/upload/rtf/',
    outputExtension: 'rtf',
  ),
  ConversionOption(
    title: 'PDF to HTML',
    description: 'Convert PDF documents to HTML files',
    icon: Icons.code,
    allowedExtensions: ['pdf'],
    endpoint: '/pdf/upload/html/',
    outputExtension: 'html',
  ),
  ConversionOption(
    title: 'PDF to PPT',
    description: 'Convert PDF documents to PowerPoint slides',
    icon: Icons.slideshow,
    allowedExtensions: ['pdf'],
    endpoint: '/pdf/upload/ppt/',
    outputExtension: 'pptx',
  ),
  ConversionOption(
    title: 'PDF to TXT',
    description: 'Extract text from PDF files',
    icon: Icons.notes,
    allowedExtensions: ['pdf'],
    endpoint: '/pdf/upload/txt/',
    outputExtension: 'txt',
  ),
];

const othersToPdf = [
  ConversionOption(
    title: 'Word to PDF',
    description: 'Convert Word documents to PDF',
    icon: Icons.picture_as_pdf,
    allowedExtensions: ['doc', 'docx'],
    endpoint: '/docx/upload/docx_to_pdf/',
    outputExtension: 'pdf',
  ),
  ConversionOption(
    title: 'RTF to PDF',
    description: 'Convert Rich Text files to PDF',
    icon: Icons.picture_as_pdf,
    allowedExtensions: ['rtf'],
    endpoint: '/rtf/upload/rtf_to_pdf/',
    outputExtension: 'pdf',
  ),
  ConversionOption(
    title: 'HTML to PDF',
    description: 'Convert HTML files to PDF',
    icon: Icons.picture_as_pdf,
    allowedExtensions: ['html', 'htm'],
    endpoint: '/html/upload/html_to_pdf/',
    outputExtension: 'pdf',
  ),
  ConversionOption(
    title: 'PPT to PDF',
    description: 'Convert PowerPoint files to PDF',
    icon: Icons.picture_as_pdf,
    allowedExtensions: ['ppt', 'pptx'],
    endpoint: '/pptx/upload/ppt_to_pdf/',
    outputExtension: 'pdf',
  ),
  ConversionOption(
    title: 'TXT to PDF',
    description: 'Convert text files to PDF',
    icon: Icons.picture_as_pdf,
    allowedExtensions: ['txt'],
    endpoint: '/txt/upload/txt_to_pdf/',
    outputExtension: 'pdf',
  ),
];

