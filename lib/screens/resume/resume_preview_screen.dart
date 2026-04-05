import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easycv/services/resume_template_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:easycv/utils/web_stubs.dart' if (dart.library.html) 'dart:html' as html;

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
  late ResumeTemplateDefinition _template;
  Map<String, dynamic> _profileData = {};

  @override
  void initState() {
    super.initState();
    _template = getTemplateById(widget.templateId);
    _loadProfileData();
  }

  String get _fullName => _text('fullName', 'Candidate Name');
  String get _headline => _text('headline', _template.role);
  String get _email => _text('email', 'candidate@email.com');
  String get _phone => _text('phone', '+91 00000 00000');
  String get _linkedIn => _text('linkedIn', 'linkedin.com/in/profile');
  String get _github => _text('github', 'portfolio.com');
  String get _location => _text('location', 'India');
  String get _summary => _text('summary', 'Professional summary not provided.');
  String get _skillsRaw => _text('skills', '');
  String get _certificationsRaw => _text('certifications', '');
  String get _languagesRaw => _text('languages', '');

  String _text(String key, String fallback) {
    final value = _profileData[key];
    if (value == null) return fallback;
    final s = value.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  List<String> _splitCsv(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> get _experiences =>
      (_profileData['experiences'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  List<Map<String, dynamic>> get _educations =>
      (_profileData['educations'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  List<Map<String, dynamic>> get _projects =>
      (_profileData['projects'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  List<String> get _skills => _splitCsv(_skillsRaw);
  List<String> get _certifications => _splitCsv(_certificationsRaw);
  List<String> get _languages => _splitCsv(_languagesRaw);

  Future<void> _loadProfileData() async {
    final sample = buildRoleSampleProfile(widget.templateId);
    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _profileData = sample;
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final remote = doc.data()?['profileData'];
      if (remote is Map<String, dynamic>) {
        _profileData = mergeProfileData(sample, remote);
      } else {
        _profileData = sample;
      }
    } catch (_) {
      _profileData = sample;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<_PdfFontSet> _loadPdfFonts() async {
    if (_template.id == 'architectural_grid') {
      return _PdfFontSet(
        name: await PdfGoogleFonts.ralewayExtraBold(),
        heading: await PdfGoogleFonts.sourceSans3SemiBold(),
        body: await PdfGoogleFonts.sourceSans3Regular(),
        bodyBold: await PdfGoogleFonts.sourceSans3SemiBold(),
      );
    }
    if (_template.id == 'executive_prestige') {
      return _PdfFontSet(
        name: await PdfGoogleFonts.playfairDisplayBold(),
        heading: await PdfGoogleFonts.playfairDisplayBold(),
        body: await PdfGoogleFonts.sourceSans3Regular(),
        bodyBold: await PdfGoogleFonts.sourceSans3SemiBold(),
      );
    }
    if (_template.id == 'creative_professional') {
      return _PdfFontSet(
        name: await PdfGoogleFonts.nunitoExtraBold(),
        heading: await PdfGoogleFonts.nunitoBold(),
        body: await PdfGoogleFonts.nunitoRegular(),
        bodyBold: await PdfGoogleFonts.nunitoSemiBold(),
      );
    }

    if (_template.id == 'hr_people_ops') {
      return _PdfFontSet(
        name: await PdfGoogleFonts.playfairDisplayBold(),
        heading: await PdfGoogleFonts.playfairDisplayBold(),
        body: await PdfGoogleFonts.sourceSans3Regular(),
        bodyBold: await PdfGoogleFonts.sourceSans3SemiBold(),
      );
    }
    if (_template.id == 'data_science_insight') {
      return _PdfFontSet(
        name: await PdfGoogleFonts.nunitoExtraBold(),
        heading: await PdfGoogleFonts.nunitoBold(),
        body: await PdfGoogleFonts.nunitoRegular(),
        bodyBold: await PdfGoogleFonts.nunitoSemiBold(),
      );
    }

    return _PdfFontSet(
      name: await PdfGoogleFonts.ralewayBold(),
      heading: await PdfGoogleFonts.sourceSans3Bold(),
      body: await PdfGoogleFonts.sourceSans3Regular(),
      bodyBold: await PdfGoogleFonts.sourceSans3SemiBold(),
    );
  }

  Future<pw.Document> _generatePDF() async {
    final fonts = await _loadPdfFonts();
    final pdf = pw.Document();

    if (_template.id == 'architectural_grid') {
      _buildTemplate4Architectural(pdf, fonts);
    } else if (_template.id == 'executive_prestige') {
      _buildTemplate5Prestige(pdf, fonts);
    } else if (_template.id == 'creative_professional') {
      _buildTemplate6Creative(pdf, fonts);
    } else if (_template.id == 'hr_people_ops') {
      _buildTemplate2Finance(pdf, fonts);
    } else if (_template.id == 'data_science_insight') {
      _buildTemplate3Modern(pdf, fonts);
    } else {
      _buildTemplate1Faang(pdf, fonts);
    }

    return pdf;
  }

  void _buildTemplate1Faang(pw.Document pdf, _PdfFontSet f) {
    final navy = PdfColor.fromHex('#1A3557');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => [
          pw.Text(
            _fullName.toUpperCase(),
            style: pw.TextStyle(
              font: f.name,
              fontSize: 29,
              letterSpacing: 1.1,
              color: navy,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _headline,
            style: pw.TextStyle(font: f.body, fontSize: 12, color: navy),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '$_email | $_phone | $_linkedIn | $_github | $_location',
            style: pw.TextStyle(font: f.body, fontSize: 10, color: PdfColor.fromHex('#555555')),
          ),
          pw.SizedBox(height: 10),
          pw.Container(height: 1, color: navy),
          pw.SizedBox(height: 14),
          _t1Header('SUMMARY', navy, f),
          _bodyParagraph(_summary, f),
          pw.SizedBox(height: 14),
          _t1Header('EXPERIENCE', navy, f),
          ..._experienceBlocks(f, navy, showLocation: false),
          pw.SizedBox(height: 14),
          _t1Header('EDUCATION', navy, f),
          ..._educationBlocks(f),
          pw.SizedBox(height: 14),
          _t1Header('SKILLS', navy, f),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _skills
                .map(
                  (s) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F2F4F7'),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Text(
                      s,
                      style: pw.TextStyle(font: f.body, fontSize: 10, color: PdfColor.fromHex('#222222')),
                    ),
                  ),
                )
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _t1Header('CERTIFICATIONS', navy, f),
          _bulletLines(_certifications, f),
          pw.SizedBox(height: 14),
          _t1Header('PROJECTS', navy, f),
          ..._projectBlocks(f),
        ],
      ),
    );
  }

  void _buildTemplate2Finance(pw.Document pdf, _PdfFontSet f) {
    final charcoal = PdfColor.fromHex('#1C1C1C');
    final gold = PdfColor.fromHex('#C9A84C');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => [
          pw.Container(
            width: double.infinity,
            color: charcoal,
            padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _fullName.toUpperCase(),
                  style: pw.TextStyle(font: f.name, fontSize: 27, color: PdfColors.white),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _headline,
                  style: pw.TextStyle(font: f.body, fontSize: 12, color: PdfColors.white),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '$_email | $_phone | $_linkedIn | $_location',
                  style: pw.TextStyle(font: f.body, fontSize: 10, color: PdfColor.fromHex('#E2E2E2')),
                ),
              ],
            ),
          ),
          pw.Container(height: 1, color: gold),
          pw.SizedBox(height: 14),
          _t2Header('SUMMARY', f),
          _bodyParagraph(_summary, f),
          pw.SizedBox(height: 12),
          _t2Header('EXPERIENCE', f),
          ..._experienceBlocks(f, PdfColor.fromHex('#2D2D2D'), showLocation: true, dense: true),
          pw.SizedBox(height: 12),
          _t2Header('EDUCATION', f),
          ..._educationBlocks(f),
          pw.SizedBox(height: 12),
          _t2Header('SKILLS', f),
          pw.Text(_skills.join(', '), style: pw.TextStyle(font: f.body, fontSize: 10.2)),
          pw.SizedBox(height: 12),
          _t2Header('CERTIFICATIONS', f),
          pw.Text(_certifications.join(', '), style: pw.TextStyle(font: f.body, fontSize: 10.2)),
          pw.SizedBox(height: 12),
          _t2Header('PROJECTS', f),
          ..._projectBlocks(f),
        ],
      ),
    );
  }

  void _buildTemplate3Modern(pw.Document pdf, _PdfFontSet f) {
    final blue = PdfColor.fromHex('#0073B1');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  color: PdfColor.fromHex('#F5F5F5'),
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _fullName,
                        style: pw.TextStyle(font: f.name, fontSize: 20, color: PdfColor.fromHex('#222222')),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(_headline, style: pw.TextStyle(font: f.body, fontSize: 10.5, color: blue)),
                      pw.SizedBox(height: 10),
                      _t3SideHeader('CONTACT', blue, f),
                      _sideText(_email, f),
                      _sideText(_phone, f),
                      _sideText(_linkedIn, f),
                      _sideText(_location, f),
                      pw.SizedBox(height: 10),
                      _t3SideHeader('SKILLS', blue, f),
                      ..._skills.take(8).map((s) => _skillBar(s, 0.8, blue, f)).toList(),
                      pw.SizedBox(height: 10),
                      _t3SideHeader('LANGUAGES', blue, f),
                      ..._languages.map((l) => _sideBullet(l, f)).toList(),
                      pw.SizedBox(height: 10),
                      _t3SideHeader('CERTIFICATIONS', blue, f),
                      ..._certifications.map((c) => _sideBullet(c, f)).toList(),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                flex: 7,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _t1Header('SUMMARY', blue, f),
                    _bodyParagraph(_summary, f),
                    pw.SizedBox(height: 12),
                    _t1Header('EXPERIENCE', blue, f),
                    ..._experienceBlocks(
                      f,
                      blue,
                      showLocation: false,
                      withCardBorder: true,
                    ),
                    pw.SizedBox(height: 12),
                    _t1Header('EDUCATION', blue, f),
                    ..._educationBlocks(f),
                    pw.SizedBox(height: 12),
                    _t1Header('SKILLS', blue, f),
                    _bodyParagraph(_skills.join(', '), f),
                    pw.SizedBox(height: 12),
                    _t1Header('CERTIFICATIONS', blue, f),
                    _bulletLines(_certifications, f),
                    pw.SizedBox(height: 12),
                    _t1Header('PROJECTS', blue, f),
                    ..._projectBlocks(f),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _buildTemplate4Architectural(pw.Document pdf, _PdfFontSet f) {
    final black = PdfColor.fromHex('#0D0D0D');
    final midGray = PdfColor.fromHex('#666666');
    final lightGray = PdfColor.fromHex('#999999');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 6,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _fullName.toUpperCase(),
                      style: pw.TextStyle(
                        font: f.name,
                        fontSize: 32,
                        letterSpacing: 1.2,
                        color: black,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      _headline,
                      style: pw.TextStyle(font: f.body, fontSize: 11, color: black),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(_email, style: pw.TextStyle(font: f.body, fontSize: 10, color: midGray)),
                    pw.SizedBox(height: 6),
                    pw.Text(_phone, style: pw.TextStyle(font: f.body, fontSize: 10, color: midGray)),
                    pw.SizedBox(height: 6),
                    pw.Text(_linkedIn, style: pw.TextStyle(font: f.body, fontSize: 10, color: midGray)),
                    pw.SizedBox(height: 6),
                    pw.Text(_location, style: pw.TextStyle(font: f.body, fontSize: 10, color: midGray)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(height: 1, color: black),
          pw.SizedBox(height: 18),
          ..._architectSection(
            label: 'SUMMARY',
            content: [_bodyParagraph(_summary, f)],
            f: f,
            lightGray: lightGray,
          ),
          ..._architectSection(
            label: 'EXPERIENCE',
            content: _experienceBlocks(f, black, showLocation: false),
            f: f,
            lightGray: lightGray,
          ),
          ..._architectSection(
            label: 'EDUCATION',
            content: _educationBlocks(f),
            f: f,
            lightGray: lightGray,
          ),
          ..._architectSection(
            label: 'SKILLS',
            content: [pw.Text(_skills.join(', '), style: pw.TextStyle(font: f.body, fontSize: 10.2))],
            f: f,
            lightGray: lightGray,
          ),
          ..._architectSection(
            label: 'PROJECTS',
            content: _projectBlocks(f),
            f: f,
            lightGray: lightGray,
          ),
          ..._architectSection(
            label: 'CERTIFICATIONS',
            content: [_bulletLines(_certifications, f)],
            f: f,
            lightGray: lightGray,
          ),
        ],
      ),
    );
  }

  void _buildTemplate5Prestige(pw.Document pdf, _PdfFontSet f) {
    final burgundy = PdfColor.fromHex('#6B1D1D');
    final nearBlack = PdfColor.fromHex('#1A1A1A');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => [
          pw.Center(
            child: pw.Text(
              _fullName,
              style: pw.TextStyle(font: f.name, fontSize: 30, color: burgundy),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text(
              _headline.toUpperCase(),
              style: pw.TextStyle(font: f.heading, fontSize: 11, letterSpacing: 1.2, color: PdfColor.fromHex('#555555')),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: pw.Text(
              '$_email · $_phone · $_linkedIn · $_location',
              style: pw.TextStyle(font: f.body, fontSize: 10, color: PdfColor.fromHex('#555555')),
            ),
          ),
          pw.SizedBox(height: 10),
          _doubleRule(burgundy),
          pw.SizedBox(height: 12),
          _prestigeSection('SUMMARY', [_summaryParagraphPrestige(f)], f, burgundy, nearBlack),
          _prestigeSection('EXPERIENCE', _experiencePrestige(f), f, burgundy, nearBlack),
          _prestigeSection('EDUCATION', _educationPrestige(f), f, burgundy, nearBlack),
          _prestigeSection(
            'SKILLS',
            [pw.Text(_skills.join(', '), style: pw.TextStyle(font: f.body, fontSize: 10.2, color: nearBlack))],
            f,
            burgundy,
            nearBlack,
          ),
          _prestigeSection('PROJECTS', _projectBlocks(f), f, burgundy, nearBlack),
          _prestigeSection(
            'CERTIFICATIONS',
            [pw.Text(_certifications.join(', '), style: pw.TextStyle(font: f.body, fontSize: 10.2, color: nearBlack))],
            f,
            burgundy,
            nearBlack,
          ),
        ],
      ),
    );
  }

  void _buildTemplate6Creative(pw.Document pdf, _PdfFontSet f) {
    final accent = PdfColor.fromHex('#1B4332');
    final dark = PdfColor.fromHex('#121212');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(width: 6, height: 74, color: accent),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(_fullName, style: pw.TextStyle(font: f.name, fontSize: 26, color: dark)),
                    pw.SizedBox(height: 4),
                    pw.Text(_headline, style: pw.TextStyle(font: f.bodyBold, fontSize: 12, color: accent)),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '$_email · $_phone · $_linkedIn · $_github · $_location',
                      style: pw.TextStyle(font: f.body, fontSize: 10, color: PdfColor.fromHex('#555555')),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          _creativeHeader('SUMMARY', accent, f),
          _bodyParagraph(_summary, f),
          pw.SizedBox(height: 12),
          _creativeHeader('EXPERIENCE', accent, f),
          ..._creativeExperienceBlocks(f, accent),
          pw.SizedBox(height: 12),
          _creativeHeader('EDUCATION', accent, f),
          ..._educationBlocks(f),
          pw.SizedBox(height: 12),
          _creativeHeader('SKILLS', accent, f),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _skills
                .map(
                  (s) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#EEEEEE'),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Text(
                      s,
                      style: pw.TextStyle(font: f.body, fontSize: 10, color: PdfColor.fromHex('#333333')),
                    ),
                  ),
                )
                .toList(),
          ),
          pw.SizedBox(height: 12),
          _creativeHeader('PROJECTS', accent, f),
          ..._projectBlocks(f),
          pw.SizedBox(height: 12),
          _creativeHeader('CERTIFICATIONS', accent, f),
          _triangleBulletLines(_certifications, f),
        ],
      ),
    );
  }

  List<pw.Widget> _architectSection({
    required String label,
    required List<pw.Widget> content,
    required _PdfFontSet f,
    required PdfColor lightGray,
  }) {
    return [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 52,
            padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Center(
              child: pw.Transform.rotateBox(
                angle: -math.pi / 2,
                child: pw.Text(
                  label,
                  style: pw.TextStyle(font: f.heading, fontSize: 8, letterSpacing: 2.8, color: lightGray),
                ),
              ),
            ),
          ),
          pw.Container(width: 0.5, height: 86, color: PdfColor.fromHex('#D0D0D0')),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 12),
    ];
  }

  pw.Widget _doubleRule(PdfColor burgundy) {
    return pw.Column(
      children: [
        pw.Container(height: 1.5, color: burgundy),
        pw.SizedBox(height: 4),
        pw.Container(height: 0.5, color: burgundy),
      ],
    );
  }

  pw.Widget _summaryParagraphPrestige(_PdfFontSet f) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16),
      child: pw.Text(
        _summary,
        textAlign: pw.TextAlign.justify,
        style: pw.TextStyle(font: f.body, fontSize: 10.2, lineSpacing: 3.0, color: PdfColor.fromHex('#1A1A1A')),
      ),
    );
  }

  pw.Widget _prestigeSection(
    String label,
    List<pw.Widget> content,
    _PdfFontSet f,
    PdfColor burgundy,
    PdfColor textColor,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _doubleRule(burgundy),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              label,
              style: pw.TextStyle(font: f.heading, fontSize: 10.3, letterSpacing: 1.8, color: textColor),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Container(height: 0.5, color: burgundy),
          pw.SizedBox(height: 8),
          ...content,
        ],
      ),
    );
  }

  List<pw.Widget> _experiencePrestige(_PdfFontSet f) {
    return _experiences
        .map(
          (exp) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    exp['duration']?.toString() ?? '',
                    style: pw.TextStyle(
                      font: f.body,
                      fontSize: 9.8,
                      color: PdfColor.fromHex('#666666'),
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
                pw.Text(
                  exp['jobTitle']?.toString() ?? '',
                  style: pw.TextStyle(font: f.bodyBold, fontSize: 11.2, color: PdfColor.fromHex('#1A1A1A')),
                ),
                pw.Text(
                  exp['company']?.toString() ?? '',
                  style: pw.TextStyle(
                    font: f.body,
                    fontSize: 10.6,
                    color: PdfColor.fromHex('#1A1A1A'),
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.SizedBox(height: 4),
                ..._highlightsFromExperience(exp).map(
                  (line) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      '— $line',
                      style: pw.TextStyle(font: f.body, fontSize: 10.1, lineSpacing: 2.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  List<pw.Widget> _educationPrestige(_PdfFontSet f) {
    return _educations
        .map(
          (edu) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    edu['year']?.toString() ?? '',
                    style: pw.TextStyle(
                      font: f.body,
                      fontSize: 9.8,
                      color: PdfColor.fromHex('#666666'),
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
                pw.Text(
                  edu['course']?.toString() ?? '',
                  style: pw.TextStyle(font: f.bodyBold, fontSize: 11.2, color: PdfColor.fromHex('#1A1A1A')),
                ),
                pw.Text(
                  edu['university']?.toString() ?? '',
                  style: pw.TextStyle(
                    font: f.body,
                    fontSize: 10.6,
                    color: PdfColor.fromHex('#1A1A1A'),
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                if ((edu['grade'] ?? '').toString().isNotEmpty)
                  pw.Text(
                    'Grade: ${edu['grade']}',
                    style: pw.TextStyle(font: f.body, fontSize: 10.1, color: PdfColor.fromHex('#1A1A1A')),
                  ),
              ],
            ),
          ),
        )
        .toList();
  }

  pw.Widget _creativeHeader(String label, PdfColor accent, _PdfFontSet f) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: f.heading, fontSize: 12, letterSpacing: 2.4, color: accent),
        ),
        pw.SizedBox(height: 2),
        pw.Container(width: 40, height: 0.5, color: accent),
      ],
    );
  }

  List<pw.Widget> _creativeExperienceBlocks(_PdfFontSet f, PdfColor accent) {
    return _experiences
        .map(
          (exp) => pw.Container(
            margin: const pw.EdgeInsets.only(top: 8, bottom: 8),
            padding: const pw.EdgeInsets.only(left: 10),
            decoration: pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(width: 2, color: accent)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        exp['jobTitle']?.toString() ?? '',
                        style: pw.TextStyle(font: f.bodyBold, fontSize: 11.5),
                      ),
                    ),
                    pw.Text(
                      '${exp['duration'] ?? ''} | ${exp['location'] ?? _location}',
                      style: pw.TextStyle(font: f.body, fontSize: 9.2, color: PdfColor.fromHex('#666666')),
                    ),
                  ],
                ),
                pw.Text(
                  exp['company']?.toString() ?? '',
                  style: pw.TextStyle(font: f.bodyBold, fontSize: 11, color: accent),
                ),
                pw.SizedBox(height: 5),
                ..._highlightsFromExperience(exp).map(
                  (line) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      '▸ $line',
                      style: pw.TextStyle(font: f.body, fontSize: 10, lineSpacing: 2.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  pw.Widget _triangleBulletLines(List<String> items, _PdfFontSet f) {
    if (items.isEmpty) {
      return pw.Text('-', style: pw.TextStyle(font: f.body, fontSize: 10.2));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items
          .map(
            (line) => pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                '▸ $line',
                style: pw.TextStyle(font: f.body, fontSize: 10.1, lineSpacing: 2.3),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _t1Header(String text, PdfColor accent, _PdfFontSet f) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(width: 3.5, height: 14, color: accent),
        pw.SizedBox(width: 7),
        pw.Text(
          text,
          style: pw.TextStyle(font: f.heading, fontSize: 12, color: PdfColor.fromHex('#111111')),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(child: pw.Container(height: 0.5, color: PdfColor.fromHex('#C8CDD2'))),
      ],
    );
  }

  pw.Widget _t2Header(String text, _PdfFontSet f) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(height: 0.5, color: PdfColor.fromHex('#202020')),
        pw.SizedBox(height: 2),
        pw.Text(
          text,
          style: pw.TextStyle(font: f.heading, fontSize: 11.5, color: PdfColor.fromHex('#111111')),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 0.5, color: PdfColor.fromHex('#202020')),
      ],
    );
  }

  pw.Widget _t3SideHeader(String text, PdfColor accent, _PdfFontSet f) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: f.heading, fontSize: 9.8, color: accent),
      ),
    );
  }

  pw.Widget _bodyParagraph(String text, _PdfFontSet f) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 7),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: f.body,
          fontSize: 10.2,
          lineSpacing: 2.8,
          color: PdfColor.fromHex('#1E1E1E'),
        ),
      ),
    );
  }

  List<pw.Widget> _experienceBlocks(
    _PdfFontSet f,
    PdfColor accent, {
    required bool showLocation,
    bool dense = false,
    bool withCardBorder = false,
  }) {
    return _experiences.map((exp) {
      final highlights = _highlightsFromExperience(exp);
      final body = pw.Container(
        padding: pw.EdgeInsets.only(bottom: dense ? 6 : 9),
        decoration: withCardBorder
            ? pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#D7DDE4'), width: 0.6)),
              )
            : null,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    exp['jobTitle']?.toString() ?? '',
                    style: pw.TextStyle(
                      font: f.bodyBold,
                      fontSize: 11,
                      color: accent,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
                pw.Text(
                  exp['duration']?.toString() ?? '',
                  style: pw.TextStyle(font: f.bodyBold, fontSize: 10, color: PdfColor.fromHex('#666666')),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    exp['company']?.toString() ?? '',
                    style: pw.TextStyle(font: f.bodyBold, fontSize: 11, color: PdfColor.fromHex('#222222')),
                  ),
                ),
                if (showLocation)
                  pw.Text(
                    exp['location']?.toString() ?? _location,
                    style: pw.TextStyle(font: f.body, fontSize: 10, color: PdfColor.fromHex('#666666')),
                  ),
              ],
            ),
            pw.SizedBox(height: dense ? 4 : 6),
            ...highlights.map(
              (line) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  '— $line',
                  style: pw.TextStyle(font: f.body, fontSize: 10.1, lineSpacing: 2.2),
                ),
              ),
            ),
          ],
        ),
      );
      return body;
    }).toList();
  }

  List<pw.Widget> _educationBlocks(_PdfFontSet f) {
    return _educations
        .map(
          (edu) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 7, bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        edu['course']?.toString() ?? '',
                        style: pw.TextStyle(font: f.bodyBold, fontSize: 11),
                      ),
                    ),
                    pw.Text(
                      edu['year']?.toString() ?? '',
                      style: pw.TextStyle(font: f.bodyBold, fontSize: 10, color: PdfColor.fromHex('#666666')),
                    ),
                  ],
                ),
                pw.Text(
                  '${edu['university'] ?? ''}${(edu['grade'] ?? '').toString().isNotEmpty ? ' | ${edu['grade']}' : ''}',
                  style: pw.TextStyle(font: f.body, fontSize: 10.1),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  List<pw.Widget> _projectBlocks(_PdfFontSet f) {
    return _projects
        .map(
          (project) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6, bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  project['name']?.toString() ?? '',
                  style: pw.TextStyle(font: f.bodyBold, fontSize: 11),
                ),
                if ((project['description'] ?? '').toString().isNotEmpty)
                  pw.Text(
                    '— ${project['description']}',
                    style: pw.TextStyle(font: f.body, fontSize: 10.1, lineSpacing: 2.2),
                  ),
                if ((project['technologies'] ?? '').toString().isNotEmpty)
                  pw.Text(
                    'Stack: ${project['technologies']}',
                    style: pw.TextStyle(font: f.body, fontSize: 10),
                  ),
              ],
            ),
          ),
        )
        .toList();
  }

  pw.Widget _bulletLines(List<String> items, _PdfFontSet f) {
    if (items.isEmpty) {
      return pw.Text('-', style: pw.TextStyle(font: f.body, fontSize: 10.2));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items
          .map(
            (line) => pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5),
              child: pw.Text(
                '— $line',
                style: pw.TextStyle(font: f.body, fontSize: 10.1, lineSpacing: 2.2),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _skillBar(String skill, double level, PdfColor blue, _PdfFontSet f) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(skill, style: pw.TextStyle(font: f.body, fontSize: 10)),
          pw.SizedBox(height: 2),
          pw.Container(
            height: 4,
            width: double.infinity,
            color: PdfColor.fromHex('#D4DADF'),
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Container(width: 120 * level, color: blue),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _sideText(String text, _PdfFontSet f) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(text, style: pw.TextStyle(font: f.body, fontSize: 10)),
    );
  }

  pw.Widget _sideBullet(String text, _PdfFontSet f) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text('— $text', style: pw.TextStyle(font: f.body, fontSize: 10)),
    );
  }

  List<String> _highlightsFromExperience(Map<String, dynamic> exp) {
    final highlights = exp['highlights'];
    if (highlights is List) {
      final lines = highlights.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      if (lines.isNotEmpty) return lines;
    }

    final description = exp['description']?.toString().trim() ?? '';
    if (description.isNotEmpty) {
      return [description];
    }
    return ['Delivered high-impact outcomes with measurable business improvements.'];
  }

  Future<void> _saveResume() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final title =
          '$_fullName - ${_template.name} - ${DateTime.now().toString().split(' ')[0]}';

      await _firestore.collection('users').doc(user.uid).collection('resumes').add({
        'title': title,
        'templateType': widget.templateId,
        'createdAt': FieldValue.serverTimestamp(),
        'content': _profileData,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resume saved successfully!'),
          backgroundColor: Color(0xFF0e5bbc),
        ),
      );
      Navigator.of(context).popUntil((route) => route.settings.name == '/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving resume: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadPDF() async {
    try {
      final doc = await _generatePDF();
      final bytes = await doc.save();

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '${_fullName.replaceAll(' ', '_')}_${_template.id}.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        await Printing.sharePdf(
          bytes: bytes,
          filename: '${_fullName.replaceAll(' ', '_')}_${_template.id}.pdf',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 248, 250, 255),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0e5bbc)),
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
        title: Text(
          '${_template.name} Preview',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
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
      body: PdfPreview(
        build: (format) async {
          final doc = await _generatePDF();
          return doc.save();
        },
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: '${_fullName.replaceAll(' ', '_')}_${_template.id}.pdf',
      ),
    );
  }
}

class _PdfFontSet {
  final pw.Font name;
  final pw.Font heading;
  final pw.Font body;
  final pw.Font bodyBold;

  _PdfFontSet({
    required this.name,
    required this.heading,
    required this.body,
    required this.bodyBold,
  });
}
