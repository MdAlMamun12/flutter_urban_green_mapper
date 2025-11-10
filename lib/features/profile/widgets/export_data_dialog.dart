import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:urban_green_mapper/core/models/report_model.dart';
import 'package:urban_green_mapper/core/models/participation_model.dart';
import 'package:urban_green_mapper/core/models/plant_model.dart';
import 'package:urban_green_mapper/features/profile/providers/profile_provider.dart';

class ExportDataDialog extends StatefulWidget {
  final ProfileProvider profileProvider;

  const ExportDataDialog({
    super.key,
    required this.profileProvider,
  });

  @override
  State<ExportDataDialog> createState() => _ExportDataDialogState();
}

class _ExportDataDialogState extends State<ExportDataDialog> {
  bool _isExporting = false;
  String _selectedFormat = 'PDF';
  final List<String> _exportFormats = ['PDF', 'JSON', 'CSV'];

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Ensure data is loaded
      if (widget.profileProvider.user == null) {
        final currentUser = widget.profileProvider.user;
        if (currentUser != null) {
          await widget.profileProvider.loadUserProfile(currentUser.userId);
        }
      }

      switch (_selectedFormat) {
        case 'PDF':
          await _exportToPdf();
          break;
        case 'JSON':
          await _exportToJson();
          break;
        case 'CSV':
          await _exportToCsv();
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      // Add user profile page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              _buildPdfHeader(),
              _buildUserProfileSection(),
              _buildStatisticsSection(),
              _buildReportsSection(),
              _buildEventsSection(),
              _buildPlantsSection(),
            ];
          },
        ),
      );

      // Save PDF to temporary directory
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/urban_green_mapper_data_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'My Urban Green Mapper Data Export');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exported successfully and ready to share!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      throw Exception('PDF export failed: $e');
    }
  }

  Future<void> _exportToJson() async {
    try {
      final jsonData = await widget.profileProvider.exportUserData();
      
      // Save JSON to temporary directory
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/urban_green_mapper_data_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonData);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'My Urban Green Mapper Data Export (JSON)');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('JSON data exported successfully and ready to share!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      throw Exception('JSON export failed: $e');
    }
  }

  Future<void> _exportToCsv() async {
    try {
      final user = widget.profileProvider.user;
      final stats = widget.profileProvider.userStatistics;
      final reports = widget.profileProvider.userReports;
      final participations = widget.profileProvider.userParticipations;
      final plants = widget.profileProvider.adoptedPlants;

      // Build CSV content
      final csvContent = StringBuffer();

      // User Profile Section
      csvContent.writeln('USER PROFILE');
      csvContent.writeln('Name,Email,Role,Impact Score,Member Since');
      csvContent.writeln('"${user?.name ?? 'N/A'}","${user?.email ?? 'N/A'}","${user?.role ?? 'N/A'}",'
          '${user?.impactScore ?? 0},"${user?.createdAt.toString() ?? 'N/A'}"');
      csvContent.writeln();

      // Statistics Section
      csvContent.writeln('STATISTICS');
      csvContent.writeln('Metric,Value');
      csvContent.writeln('Total Reports,${stats['total_reports'] ?? 0}');
      csvContent.writeln('Approved Reports,${stats['approved_reports'] ?? 0}');
      csvContent.writeln('Events Joined,${stats['total_events_joined'] ?? 0}');
      csvContent.writeln('Events Attended,${stats['attended_events'] ?? 0}');
      csvContent.writeln('Volunteer Hours,${stats['total_volunteer_hours'] ?? 0}');
      csvContent.writeln('Plants Adopted,${stats['adopted_plants_count'] ?? 0}');
      csvContent.writeln();

      // Reports Section
      if (reports.isNotEmpty) {
        csvContent.writeln('ACTIVITY REPORTS');
        csvContent.writeln('Report ID,Type,Status,Created At,Description');
        for (final report in reports) {
          final escapedDescription = report.description.replaceAll('"', '""');
          csvContent.writeln('"${report.reportId}","${report.type}","${report.status}",'
              '"${report.createdAt}","$escapedDescription"');
        }
        csvContent.writeln();
      }

      // Events Section
      if (participations.isNotEmpty) {
        csvContent.writeln('EVENT PARTICIPATIONS');
        csvContent.writeln('Event ID,Status,Hours Contributed,Joined At');
        for (final participation in participations) {
          csvContent.writeln('"${participation.eventId}","${participation.status}",'
              '${participation.hoursContributed},"${participation.joinedAt}"');
        }
        csvContent.writeln();
      }

      // Plants Section
      if (plants.isNotEmpty) {
        csvContent.writeln('ADOPTED PLANTS');
        csvContent.writeln('Plant ID,Species,Planting Date,Health Status');
        for (final plant in plants) {
          csvContent.writeln('"${plant.plantId}","${plant.species}",'
              '"${plant.plantingDate}","${plant.healthStatus}"');
        }
      }

      // Save CSV to temporary directory
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/urban_green_mapper_data_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csvContent.toString());

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'My Urban Green Mapper Data Export (CSV)');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV data exported successfully and ready to share!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      throw Exception('CSV export failed: $e');
    }
  }

  // PDF Building Methods
  pw.Widget _buildPdfHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.green100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Urban Green Mapper',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'User Data Export',
            style: pw.TextStyle(
              fontSize: 16,
              color: PdfColors.green700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on: ${DateTime.now().toString()}',
            style: pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildUserProfileSection() {
    final user = widget.profileProvider.user;
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'User Profile',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildTableRow('Name', user?.name ?? 'N/A'),
              _buildTableRow('Email', user?.email ?? 'N/A'),
              _buildTableRow('Role', user?.roleDisplay ?? 'N/A'),
              _buildTableRow('Impact Score', '${user?.impactScore ?? 0}'),
              _buildTableRow('Member Since', user?.createdAt.toString() ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  pw.Widget _buildStatisticsSection() {
    final stats = widget.profileProvider.userStatistics;
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Impact Statistics',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildStatRow('Total Reports', '${stats['total_reports'] ?? 0}'),
              _buildStatRow('Approved Reports', '${stats['approved_reports'] ?? 0}'),
              _buildStatRow('Pending Reports', '${stats['pending_reports'] ?? 0}'),
              _buildStatRow('Events Joined', '${stats['total_events_joined'] ?? 0}'),
              _buildStatRow('Events Attended', '${stats['attended_events'] ?? 0}'),
              _buildStatRow('Volunteer Hours', '${stats['total_volunteer_hours'] ?? 0}'),
              _buildStatRow('Plants Adopted', '${stats['adopted_plants_count'] ?? 0}'),
              _buildStatRow('Report Approval Rate', '${(stats['report_approval_rate'] ?? 0).toStringAsFixed(1)}%'),
              _buildStatRow('Event Attendance Rate', '${(stats['event_attendance_rate'] ?? 0).toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildStatRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  pw.Widget _buildReportsSection() {
    final reports = widget.profileProvider.userReports;
    if (reports.isEmpty) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Activity Reports',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
            ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('No reports submitted yet.'),
          ],
        ),
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Activity Reports (${reports.length})',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              _buildReportHeaderRow(),
              for (final report in reports.take(10)) // Limit to first 10 for PDF
                _buildReportDataRow(report),
            ],
          ),
          if (reports.length > 10)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 8),
              child: pw.Text('... and ${reports.length - 10} more reports'),
            ),
        ],
      ),
    );
  }

  pw.TableRow _buildReportHeaderRow() {
    return pw.TableRow(
      children: [
        _buildHeaderCell('Description'),
        _buildHeaderCell('Type'),
        _buildHeaderCell('Status'),
        _buildHeaderCell('Date'),
      ],
    );
  }

  pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.TableRow _buildReportDataRow(ReportModel report) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(report.shortDescription),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(report.type),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(report.status),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(report.createdAt.toString().split(' ')[0]),
        ),
      ],
    );
  }

  pw.Widget _buildEventsSection() {
    final participations = widget.profileProvider.userParticipations;
    if (participations.isEmpty) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Event Participations',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('No event participations yet.'),
          ],
        ),
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Event Participations (${participations.length})',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
            },
            children: [
              _buildEventHeaderRow(),
              for (final participation in participations.take(10)) // Limit to first 10 for PDF
                _buildEventDataRow(participation),
            ],
          ),
          if (participations.length > 10)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 8),
              child: pw.Text('... and ${participations.length - 10} more participations'),
            ),
        ],
      ),
    );
  }

  pw.TableRow _buildEventHeaderRow() {
    return pw.TableRow(
      children: [
        _buildHeaderCell('Event ID'),
        _buildHeaderCell('Status'),
        _buildHeaderCell('Hours'),
      ],
    );
  }

  pw.TableRow _buildEventDataRow(ParticipationModel participation) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(participation.eventId),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(participation.status),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text('${participation.hoursContributed}'),
        ),
      ],
    );
  }

  pw.Widget _buildPlantsSection() {
    final plants = widget.profileProvider.adoptedPlants;
    if (plants.isEmpty) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Adopted Plants',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('No plants adopted yet.'),
          ],
        ),
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Adopted Plants (${plants.length})',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
            },
            children: [
              _buildPlantHeaderRow(),
              for (final plant in plants.take(10)) // Limit to first 10 for PDF
                _buildPlantDataRow(plant),
            ],
          ),
          if (plants.length > 10)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 8),
              child: pw.Text('... and ${plants.length - 10} more plants'),
            ),
        ],
      ),
    );
  }

  pw.TableRow _buildPlantHeaderRow() {
    return pw.TableRow(
      children: [
        _buildHeaderCell('Species'),
        _buildHeaderCell('Planting Date'),
        _buildHeaderCell('Health'),
      ],
    );
  }

  pw.TableRow _buildPlantDataRow(PlantModel plant) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(plant.species),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(plant.plantingDate.toString().split(' ')[0]),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(plant.healthStatus),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Your Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose export format:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedFormat,
            items: _exportFormats.map((format) {
              return DropdownMenuItem(
                value: format,
                child: Text(format),
              );
            }).toList(),
            onChanged: _isExporting ? null : (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your data will be exported and include:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _buildExportItem('Profile Information'),
          _buildExportItem('Activity Reports'),
          _buildExportItem('Event Participations'),
          _buildExportItem('Adopted Plants'),
          _buildExportItem('Impact Statistics'),
          const SizedBox(height: 12),
          if (_selectedFormat == 'PDF')
            _buildFormatInfo('Professional PDF document with formatted tables and sections'),
          if (_selectedFormat == 'JSON')
            _buildFormatInfo('Raw JSON data for developers and data analysis'),
          if (_selectedFormat == 'CSV')
            _buildFormatInfo('Spreadsheet-friendly CSV format for Excel/Google Sheets'),
          const SizedBox(height: 8),
          Text(
            'Note: The exported file will be saved to your device and ready to share.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _exportData,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          child: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Export Data'),
        ),
      ],
    );
  }

  Widget _buildExportItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildFormatInfo(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}