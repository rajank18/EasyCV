import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'ats_scorer.dart';

class ATSService {
  static Future<ATSResult> scoreFromBytes(
    Uint8List fileBytes, {
    String? jobDescription,
  }) async {
    if (fileBytes.isEmpty) {
      return ATSResult.empty();
    }

    PdfDocument? document;
    try {
      document = PdfDocument(inputBytes: fileBytes);
      final extractor = PdfTextExtractor(document);
      final extractedText = extractor.extractText(
        startPageIndex: 0,
        endPageIndex: document.pages.count - 1,
      );

      return ATSScorer.score(
        extractedText,
        jobDescription: jobDescription,
      );
    } catch (_) {
      return const ATSResult(
        totalScore: 0,
        breakdown: {},
        wordCount: 0,
        suggestions: [
          'Could not parse this PDF. Try a text-based PDF (not scanned image).',
        ],
      );
    } finally {
      document?.dispose();
    }
  }
}