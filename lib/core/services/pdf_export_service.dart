import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  static final PdfExportService _instance = PdfExportService._internal();
  factory PdfExportService() => _instance;
  PdfExportService._internal();

  bool _isInitialized = false;
  Directory? _exportDirectory;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _log('📁 Initializing PdfExportService...');
      
      // Request permissions only for Android
      if (Platform.isAndroid) {
        try {
          final storageStatus = await Permission.storage.status;
          if (!storageStatus.isGranted) {
            await Permission.storage.request();
          }
        } catch (e) {
          // Permission plugin may not be available in some environments (tests/desktop).
          _log('⚠️ Permission check/request failed: $e', level: 800);
        }
        // On Android 11+ consider requesting manage external storage if needed (optional)
        // if (await Permission.manageExternalStorage.isDenied) {
        //   await Permission.manageExternalStorage.request();
        // }
      }

      // Get export directory with multiple fallbacks
  _exportDirectory = await _getSafeDirectory();
      
      // Create exports subdirectory
      final exportsDir = Directory('${_exportDirectory!.path}/exports');
      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
        _log('✅ Created exports directory: ${exportsDir.path}');
      }
      
      _exportDirectory = exportsDir;
      _isInitialized = true;
      
      _log('✅ PdfExportService initialized successfully');
      _log('📁 Export directory: ${_exportDirectory!.path}');
    } catch (e) {
      _log('❌ PdfExportService initialization failed: $e', level: 1000);
      await _initializeEmergencyDirectory();
    }
  }

  Future<Directory> _getSafeDirectory() async {
    // Try multiple directory sources in order
    final List<Future<Directory> Function()> directorySources = [
      () async {
        try {
          return await getApplicationDocumentsDirectory();
        } on MissingPluginException catch (e) {
          _log('❌ getApplicationDocumentsDirectory MissingPluginException: $e', level: 1000);
          rethrow;
        } catch (e) {
          _log('❌ getApplicationDocumentsDirectory failed: $e', level: 1000);
          rethrow;
        }
      },
      () async {
        try {
          return await getTemporaryDirectory();
        } on MissingPluginException catch (e) {
          _log('❌ getTemporaryDirectory MissingPluginException: $e', level: 1000);
          rethrow;
        } catch (e) {
          _log('❌ getTemporaryDirectory failed: $e', level: 1000);
          rethrow;
        }
      },
      () async {
        try {
          return await getLibraryDirectory();
        } on MissingPluginException catch (e) {
          _log('❌ getLibraryDirectory MissingPluginException: $e', level: 1000);
          rethrow;
        } catch (e) {
          _log('❌ getLibraryDirectory failed: $e', level: 1000);
          rethrow;
        }
      },
    ];

    for (var source in directorySources) {
      try {
        final directory = await source();
        _log('✅ Using directory: ${directory.path}');
        return directory;
      } catch (e) {
        _log('⚠️ Directory source failed, trying next...: $e', level: 800);
        continue;
      }
    }

    // If all platform-specific directories fail, use a custom directory
    _log('🚨 All platform directories failed, using custom directory', level: 900);
    return Directory('${Directory.current.path}/urban_green_exports');
  }

  Future<void> _initializeEmergencyDirectory() async {
    try {
      _exportDirectory = Directory('${Directory.current.path}/urban_green_exports');
      if (!await _exportDirectory!.exists()) {
        await _exportDirectory!.create(recursive: true);
      }
      _isInitialized = true;
      _log('🚨 Using emergency directory: ${_exportDirectory!.path}', level: 900);
    } catch (e) {
      _log('❌ Emergency directory setup failed: $e', level: 1000);
      // Last resort - use temporary system directory
      _exportDirectory = Directory.systemTemp;
      _isInitialized = true;
      _log('💀 Using system temp directory: ${_exportDirectory!.path}', level: 900);
    }
  }

  Future<String> _ensureDirectoryExists() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_exportDirectory == null) {
      // Ensure we have at least system temp as a fallback
      _exportDirectory = Directory.systemTemp;
      _isInitialized = true;
    }

    if (!await _exportDirectory!.exists()) {
      await _exportDirectory!.create(recursive: true);
    }

    return _exportDirectory!.path;
  }

  // Export data to PDF
  Future<String> exportToPDF({
    required List<Map<String, dynamic>> data,
    required String fileName,
    required String title,
    String? subtitle,
  }) async {
    // Build PDF document first so we can always write it to any directory (including system temp)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeFileName = _sanitizeFileName(fileName);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              if (subtitle != null) ...[
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    subtitle,
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],

              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Exported on: ${_formatDate(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Total Records: ${data.length}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              data.isEmpty ? _buildNoDataMessage() : _buildPdfTable(data),

              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Generated by Urban Green Mapper App',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey500,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      if (!_isInitialized) await initialize();

      final exportDir = await _ensureDirectoryExists();
      final filePath = '$exportDir/${safeFileName}_$timestamp.pdf';

      _log('📄 Creating PDF: $filePath');

      final file = File(filePath);
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes, flush: true);

      _log('✅ PDF exported successfully: $filePath');
      _log('📊 File size: ${pdfBytes.length} bytes');
      return filePath;
    } on MissingPluginException catch (e) {
      _log('❌ PDF export failed due to MissingPluginException: $e', level: 1000);
      // Fallback: save into system temp directory which doesn't rely on path_provider
      final pdfBytes = await pdf.save();
      final tempDir = Directory.systemTemp;
      final fallbackFile = File('${tempDir.path}/${safeFileName}_$timestamp.pdf');
      await fallbackFile.writeAsBytes(pdfBytes, flush: true);
      _log('✅ Fallback PDF saved to system temp: ${fallbackFile.path}');
      return fallbackFile.path;
    } catch (e) {
      _log('❌ PDF export failed: $e', level: 1000);
      // Generic fallback
      try {
        final pdfBytes = await pdf.save();
        final tempDir = Directory.systemTemp;
        final fallbackFile = File('${tempDir.path}/${safeFileName}_$timestamp.pdf');
        await fallbackFile.writeAsBytes(pdfBytes, flush: true);
        _log('✅ Fallback PDF saved to system temp: ${fallbackFile.path}');
        return fallbackFile.path;
      } catch (inner) {
        _log('❌ Fallback PDF save failed: $inner', level: 1000);
        throw Exception('PDF export failed: $e');
      }
    }
  }

  // Export data to JSON
  Future<String> exportToJSON({
    required List<Map<String, dynamic>> data,
    required String fileName,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final exportDir = await _ensureDirectoryExists();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeFileName = _sanitizeFileName(fileName);
      final filePath = '$exportDir/${safeFileName}_$timestamp.json';

      _log('📊 Creating JSON: $filePath');

      final jsonData = {
        'exportedAt': DateTime.now().toIso8601String(),
        'totalRecords': data.length,
        'data': data,
      };

      final file = File(filePath);
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      await file.writeAsString(jsonString, flush: true);

      _log('✅ JSON exported successfully: $filePath');
      return filePath;
    } catch (e) {
      _log('❌ JSON export failed: $e', level: 1000);
      throw Exception('JSON export failed: $e');
    }
  }

  // Export data to CSV
  Future<String> exportToCSV({
    required List<Map<String, dynamic>> data,
    required String fileName,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final exportDir = await _ensureDirectoryExists();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeFileName = _sanitizeFileName(fileName);
      final filePath = '$exportDir/${safeFileName}_$timestamp.csv';

      _log('📋 Creating CSV: $filePath');

      if (data.isEmpty) {
        throw Exception('No data to export');
      }

      final headers = data.first.keys;
      final csvBuffer = StringBuffer();

      csvBuffer.writeln(headers.map(_escapeCsv).join(','));

      for (var row in data) {
        final values = headers.map((header) => _escapeCsv(_formatValue(row[header])));
        csvBuffer.writeln(values.join(','));
      }

      final file = File(filePath);
      final csvString = csvBuffer.toString();
      await file.writeAsString(csvString, flush: true);

      _log('✅ CSV exported successfully: $filePath');
      return filePath;
    } catch (e) {
      _log('❌ CSV export failed: $e', level: 1000);
      throw Exception('CSV export failed: $e');
    }
  }

  // Helper methods
  pw.Widget _buildPdfTable(List<Map<String, dynamic>> data) {
    final headers = data.first.keys.toList();
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
      columnWidths: {
        for (int i = 0; i < headers.length; i++) 
          i: const pw.FlexColumnWidth(1.0)
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: headers.map((header) => 
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                _capitalize(header.replaceAll('_', ' ')),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.center,
              ),
            )
          ).toList(),
        ),
        for (var row in data)
          pw.TableRow(
            children: headers.map((header) => 
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  _formatValue(row[header]),
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              )
            ).toList(),
          ),
      ],
    );
  }

  pw.Widget _buildNoDataMessage() {
    return pw.Center(
      child: pw.Text(
        'No data available for export',
        style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
      ),
    );
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_');
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is DateTime) return _formatDate(value);
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is Map || value is List) return '[Complex Data]';
    return value.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  // Print PDF functionality
  Future<void> printPDF(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final pdfData = await file.readAsBytes();
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) => pdfData,
        );
        _log('🖨️ PDF printed successfully');
      } else {
        throw Exception('File not found: $filePath');
      }
    } catch (e) {
      _log('❌ PDF printing failed: $e', level: 1000);
      throw Exception('PDF printing failed: $e');
    }
  }

  /// Create a PDF and immediately open the system share/preview dialog (uses `printing` package)
  Future<void> exportAndSharePDF({
    required List<Map<String, dynamic>> data,
    required String fileName,
    required String title,
    String? subtitle,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          header: (pw.Context ctx) {
            return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text('Records: ${data.length}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            );
          },
          build: (pw.Context ctx) => [
            data.isEmpty ? _buildNoDataMessage() : _buildPdfTable(data),
          ],
        ),
      );

      final bytes = await pdf.save();

      // Share/preview using printing package
      await Printing.sharePdf(bytes: bytes, filename: '${_sanitizeFileName(fileName)}.pdf');
    } catch (e) {
      _log('❌ exportAndSharePDF failed: $e', level: 1000);
      rethrow;
    }
  }

  // Utility methods
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      _log('⚠️ fileExists check failed: $e', level: 800);
      return false;
    }
  }

  Future<List<FileSystemEntity>> getExportedFiles() async {
    try {
      if (!_isInitialized) await initialize();
      final dir = Directory(_exportDirectory!.path);
      if (await dir.exists()) {
        return await dir.list().toList();
      }
      return [];
    } catch (e) {
      _log('❌ Error getting exported files: $e', level: 1000);
      return [];
    }
  }

  bool get isInitialized => _isInitialized;

  // Internal logger wrapper - uses dart:developer to avoid analyzer lint for `print`.
  void _log(String message, {int level = 0}) {
    developer.log(message, name: 'PdfExportService', level: level);
  }
}