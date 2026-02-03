import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:html' as html;

class ResumePreviewScreen extends StatefulWidget {
  final String templateId;
  
  const ResumePreviewScreen({
    super.key,
    required this.templateId,
  });

  static const routeName = '/resume-preview';

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  Map<String, dynamic> _profileData = {};

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _profileData = doc.data()?['profileData'] ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                color: PdfColor.fromHex('#0e5bbc'),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _profileData['fullName'] ?? 'Your Name',
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      _profileData['email'] ?? 'email@example.com',
                      style: const pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                      ),
                    ),
                    if (_profileData['phone'] != null && _profileData['phone'].toString().isNotEmpty)
                      pw.Text(
                        _profileData['phone'],
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Objective
              if (_profileData['objective'] != null && _profileData['objective'].toString().isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'OBJECTIVE',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0e5bbc'),
                      ),
                    ),
                    pw.Divider(color: PdfColor.fromHex('#0e5bbc')),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      _profileData['objective'],
                      style: const pw.TextStyle(fontSize: 12),
                      textAlign: pw.TextAlign.justify,
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),
              
              // Education
              if (_profileData['course'] != null && _profileData['course'].toString().isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EDUCATION',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0e5bbc'),
                      ),
                    ),
                    pw.Divider(color: PdfColor.fromHex('#0e5bbc')),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      _profileData['course'],
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (_profileData['university'] != null)
                      pw.Text(
                        _profileData['university'],
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    if (_profileData['grade'] != null)
                      pw.Text(
                        'Grade: ${_profileData['grade']}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    if (_profileData['year'] != null)
                      pw.Text(
                        'Year: ${_profileData['year']}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    pw.SizedBox(height: 20),
                  ],
                ),
              
              // Experience
              if (_profileData['jobTitle'] != null && _profileData['jobTitle'].toString().isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EXPERIENCE',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0e5bbc'),
                      ),
                    ),
                    pw.Divider(color: PdfColor.fromHex('#0e5bbc')),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      _profileData['jobTitle'],
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (_profileData['company'] != null)
                      pw.Text(
                        _profileData['company'],
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    if (_profileData['duration'] != null)
                      pw.Text(
                        _profileData['duration'],
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    if (_profileData['description'] != null)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Text(
                          _profileData['description'],
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                    pw.SizedBox(height: 20),
                  ],
                ),
              
              // Skills
              if (_profileData['skills'] != null && _profileData['skills'].toString().isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SKILLS',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0e5bbc'),
                      ),
                    ),
                    pw.Divider(color: PdfColor.fromHex('#0e5bbc')),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      _profileData['skills'],
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> _saveResume() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Generate a simple title
      final title = '${_profileData['fullName'] ?? 'Resume'} - ${DateTime.now().toString().split(' ')[0]}';
      
      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('resumes')
          .add({
        'title': title,
        'templateType': widget.templateId,
        'createdAt': FieldValue.serverTimestamp(),
        'atsScore': 0, // TODO: Calculate ATS score
        'content': _profileData,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume saved successfully!'),
            backgroundColor: Color(0xFF0e5bbc),
          ),
        );
        Navigator.of(context).popUntil((route) => route.settings.name == '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving resume: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPDF() async {
    try {
      final doc = await _generatePDF();
      final bytes = await doc.save();
      
      if (kIsWeb) {
        // Web download
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '${_profileData['fullName'] ?? 'resume'}_resume.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF downloaded successfully!'),
              backgroundColor: Color(0xFF0e5bbc),
            ),
          );
        }
      } else {
        // Mobile/Desktop download
        await Printing.sharePdf(
          bytes: bytes,
          filename: '${_profileData['fullName'] ?? 'resume'}_resume.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 248, 250, 255),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0e5bbc),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 250, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Resume Preview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF0e5bbc)),
            onPressed: _downloadPDF,
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF0e5bbc)),
            onPressed: _saveResume,
            tooltip: 'Save Resume',
          ),
        ],
      ),
      body: kIsWeb
          ? _buildFlutterPreview()
          : PdfPreview(
              build: (format) async {
                final doc = await _generatePDF();
                return doc.save();
              },
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: '${_profileData['fullName'] ?? 'resume'}_resume.pdf',
            ),
    );
  }

  Widget _buildFlutterPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          width: 595, // A4 width in points
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(40),
                color: const Color(0xFF0e5bbc),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profileData['fullName'] ?? 'Your Name',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _profileData['email'] ?? 'email@example.com',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    if (_profileData['phone'] != null && _profileData['phone'].toString().isNotEmpty)
                      Text(
                        _profileData['phone'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    if (_profileData['address'] != null && _profileData['address'].toString().isNotEmpty)
                      Text(
                        _profileData['address'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Objective
                    if (_profileData['objective'] != null && _profileData['objective'].toString().isNotEmpty) ...[
                      const Text(
                        'OBJECTIVE',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0e5bbc),
                        ),
                      ),
                      const Divider(color: Color(0xFF0e5bbc), thickness: 2),
                      const SizedBox(height: 12),
                      Text(
                        _profileData['objective'],
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Education
                    if (_profileData['course'] != null && _profileData['course'].toString().isNotEmpty) ...[
                      const Text(
                        'EDUCATION',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0e5bbc),
                        ),
                      ),
                      const Divider(color: Color(0xFF0e5bbc), thickness: 2),
                      const SizedBox(height: 12),
                      Text(
                        _profileData['course'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_profileData['university'] != null)
                        Text(
                          _profileData['university'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (_profileData['grade'] != null)
                            Text(
                              'Grade: ${_profileData['grade']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          if (_profileData['grade'] != null && _profileData['year'] != null)
                            const Text(' | ', style: TextStyle(fontSize: 13)),
                          if (_profileData['year'] != null)
                            Text(
                              'Year: ${_profileData['year']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Experience
                    if (_profileData['jobTitle'] != null && _profileData['jobTitle'].toString().isNotEmpty) ...[
                      const Text(
                        'EXPERIENCE',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0e5bbc),
                        ),
                      ),
                      const Divider(color: Color(0xFF0e5bbc), thickness: 2),
                      const SizedBox(height: 12),
                      Text(
                        _profileData['jobTitle'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_profileData['company'] != null)
                        Text(
                          _profileData['company'],
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      if (_profileData['duration'] != null)
                        Text(
                          _profileData['duration'],
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      if (_profileData['description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _profileData['description'],
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                    
                    // Skills
                    if (_profileData['skills'] != null && _profileData['skills'].toString().isNotEmpty) ...[
                      const Text(
                        'SKILLS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0e5bbc),
                        ),
                      ),
                      const Divider(color: Color(0xFF0e5bbc), thickness: 2),
                      const SizedBox(height: 12),
                      Text(
                        _profileData['skills'],
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // References
                    if (_profileData['references'] != null && _profileData['references'].toString().isNotEmpty) ...[
                      const Text(
                        'REFERENCES',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0e5bbc),
                        ),
                      ),
                      const Divider(color: Color(0xFF0e5bbc), thickness: 2),
                      const SizedBox(height: 12),
                      Text(
                        _profileData['references'],
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
