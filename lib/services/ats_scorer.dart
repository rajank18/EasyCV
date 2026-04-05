import 'dart:math';

/// Industry-standard ATS Resume Scorer.
///
/// Scoring breakdown (total = 100):
/// - Keyword Match        -> 30 pts
/// - Contact Info         -> 10 pts
/// - Section Structure    -> 20 pts
/// - Formatting/Parsing   -> 15 pts
/// - Quantified Impact    -> 10 pts
/// - Action Verbs         -> 8 pts
/// - Dates & Consistency  -> 7 pts
class ATSScorer {
  static const List<String> _techKeywords = [
    'javascript',
    'python',
    'java',
    'dart',
    'flutter',
    'react',
    'angular',
    'node.js',
    'sql',
    'nosql',
    'mongodb',
    'postgresql',
    'mysql',
    'redis',
    'aws',
    'azure',
    'gcp',
    'docker',
    'kubernetes',
    'ci/cd',
    'git',
    'github',
    'rest',
    'api',
    'graphql',
    'microservices',
    'agile',
    'scrum',
    'devops',
    'machine learning',
    'deep learning',
    'tensorflow',
    'pytorch',
    'nlp',
    'data analysis',
    'tableau',
    'power bi',
    'excel',
    'r',
    'spark',
    'hadoop',
    'ios',
    'android',
    'swift',
    'kotlin',
    'typescript',
    'html',
    'css',
    'linux',
    'bash',
    'terraform',
    'jenkins',
    'jira',
    'figma',
    'xcode',
  ];

  static const List<String> _softSkillKeywords = [
    'leadership',
    'communication',
    'teamwork',
    'collaboration',
    'problem solving',
    'critical thinking',
    'time management',
    'adaptability',
    'creativity',
    'project management',
    'analytical',
    'detail-oriented',
    'motivated',
    'results-driven',
    'cross-functional',
    'stakeholder',
    'mentoring',
  ];

  static const List<String> _sectionHeaders = [
    'experience',
    'work experience',
    'professional experience',
    'employment',
    'education',
    'academic background',
    'skills',
    'technical skills',
    'core competencies',
    'expertise',
    'summary',
    'objective',
    'professional summary',
    'profile',
    'projects',
    'personal projects',
    'key projects',
    'certifications',
    'certificates',
    'licenses',
    'achievements',
    'accomplishments',
    'awards',
    'publications',
    'volunteer',
    'interests',
    'languages',
  ];

  static const List<String> _actionVerbs = [
    'achieved',
    'improved',
    'developed',
    'led',
    'managed',
    'built',
    'designed',
    'implemented',
    'delivered',
    'launched',
    'created',
    'increased',
    'reduced',
    'optimized',
    'streamlined',
    'automated',
    'collaborated',
    'mentored',
    'trained',
    'analyzed',
    'engineered',
    'architected',
    'negotiated',
    'presented',
    'resolved',
    'spearheaded',
    'transformed',
    'generated',
    'coordinated',
    'facilitated',
    'established',
  ];

  static final RegExp _emailRegex =
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
  static final RegExp _phoneRegex =
      RegExp(r'(\+?\d{1,3}[\s\-]?)?\(?\d{3}\)?[\s\-]?\d{3}[\s\-]?\d{4}');
  static final RegExp _linkedinRegex =
      RegExp(r'linkedin\.com/in/[a-zA-Z0-9\-]+', caseSensitive: false);
  static final RegExp _urlRegex =
      RegExp(r'https?://[^\s]+', caseSensitive: false);
  static final RegExp _quantifierRegex = RegExp(
    r'\b\d+[\+%]?\s*(x|times|percent|%|k|m|million|billion|employees|users|clients|projects|team|years|months)?\b',
    caseSensitive: false,
  );
  static final RegExp _dateRegex = RegExp(
    r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\.?\s*\d{4}'
    r'|\b\d{4}\s*[-–]\s*(\d{4}|present|current|now)'
    r'|\b(19|20)\d{2}\b',
    caseSensitive: false,
  );
  static final RegExp _atsUnfriendlyRegex = RegExp(
    r'(table|column|header|footer|text.?box|watermark)',
    caseSensitive: false,
  );

  static ATSResult score(String resumeText, {String? jobDescription}) {
    if (resumeText.trim().isEmpty) {
      return ATSResult.empty();
    }

    final normalizedText = resumeText.toLowerCase();
    final lines = resumeText.split('\n').map((l) => l.trim()).toList();
    final wordCount =
        resumeText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    final breakdown = <String, SectionScore>{};
    breakdown['keywordMatch'] =
        _scoreKeywords(normalizedText, jobDescription?.toLowerCase());
    breakdown['contactInfo'] = _scoreContactInfo(normalizedText);
    breakdown['sectionStructure'] = _scoreSections(normalizedText, lines);
    breakdown['formatting'] =
        _scoreFormatting(resumeText, normalizedText, wordCount);
    breakdown['quantifiedImpact'] = _scoreQuantifiedImpact(resumeText);
    breakdown['actionVerbs'] = _scoreActionVerbs(normalizedText);
    breakdown['datesConsistency'] = _scoreDates(resumeText);

    final total = breakdown.values.fold<double>(0, (sum, s) => sum + s.earned);

    return ATSResult(
      totalScore: total.round().clamp(0, 100),
      breakdown: breakdown,
      wordCount: wordCount,
      suggestions: _generateSuggestions(breakdown),
    );
  }

  static SectionScore _scoreKeywords(String text, String? jdText) {
    const maxScore = 30.0;
    final techHits = _techKeywords.where((k) => text.contains(k)).length;
    final softHits = _softSkillKeywords.where((k) => text.contains(k)).length;

    final techScore = min(techHits / 8.0, 1.0) * 18;
    final softScore = min(softHits / 4.0, 1.0) * 7;

    double jdScore = 0;
    if (jdText != null && jdText.isNotEmpty) {
      final jdWords = _extractMeaningfulWords(jdText);
      final resumeWords = _extractMeaningfulWords(text);
      final matches = jdWords.where((w) => resumeWords.contains(w)).length;
      jdScore = min(matches / max(jdWords.length * 0.3, 1), 1.0) * 5;
    } else {
      jdScore = (techHits >= 5 && softHits >= 2) ? 3.0 : 1.0;
    }

    final earned =
      (techScore + softScore + jdScore).clamp(0, maxScore).toDouble();
    return SectionScore(
      label: 'Keyword Match',
      earned: earned,
      max: maxScore,
      detail: 'Tech: $techHits hits | Soft skills: $softHits hits',
    );
  }

  static SectionScore _scoreContactInfo(String text) {
    const maxScore = 10.0;
    double earned = 0;
    final details = <String>[];

    if (_emailRegex.hasMatch(text)) {
      earned += 3.5;
      details.add('Email');
    } else {
      details.add('Email missing');
    }

    if (_phoneRegex.hasMatch(text)) {
      earned += 3.0;
      details.add('Phone');
    } else {
      details.add('Phone missing');
    }

    if (_linkedinRegex.hasMatch(text)) {
      earned += 2.0;
      details.add('LinkedIn');
    } else {
      details.add('LinkedIn missing');
    }

    if (_urlRegex.hasMatch(text)) {
      earned += 1.5;
      details.add('Portfolio/URL');
    }

    return SectionScore(
      label: 'Contact Info',
      earned: earned.clamp(0, maxScore).toDouble(),
      max: maxScore,
      detail: details.join(' | '),
    );
  }

  static SectionScore _scoreSections(String text, List<String> lines) {
    const maxScore = 20.0;

    final criticalSections = {
      'experience': [
        'experience',
        'work experience',
        'employment',
        'professional experience'
      ],
      'education': ['education', 'academic', 'degree', 'university', 'college'],
      'skills': ['skills', 'competencies', 'expertise', 'technologies'],
      'summary': ['summary', 'objective', 'profile', 'about'],
    };

    final bonusSections = [
      'projects',
      'certifications',
      'achievements',
      'publications',
      'volunteer'
    ];

    var criticalFound = 0;
    for (final entry in criticalSections.entries) {
      if (entry.value.any((s) => text.contains(s))) {
        criticalFound++;
      }
    }

    final bonusFound = bonusSections.where((s) => text.contains(s)).length;

    var properHeaders = 0;
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (_sectionHeaders.any((h) => lower == h)) {
        properHeaders++;
      }
    }

    final criticalScore = (criticalFound / 4.0) * 14;
    final bonusScore = min(bonusFound / 3.0, 1.0) * 4;
    final structureScore = min(properHeaders / 4.0, 1.0) * 2;

    return SectionScore(
      label: 'Section Structure',
        earned: (criticalScore + bonusScore + structureScore)
          .clamp(0, maxScore)
          .toDouble(),
      max: maxScore,
      detail: '$criticalFound/4 critical sections | $bonusFound bonus sections',
    );
  }

  static SectionScore _scoreFormatting(
    String text,
    String normalizedText,
    int wordCount,
  ) {
    const maxScore = 15.0;
    double earned = 0;
    final details = <String>[];

    if (wordCount >= 400 && wordCount <= 800) {
      earned += 5;
      details.add('Good length ($wordCount words)');
    } else if (wordCount >= 300 && wordCount < 400) {
      earned += 3;
      details.add('Slightly short ($wordCount words)');
    } else if (wordCount > 800 && wordCount <= 1200) {
      earned += 3;
      details.add('Slightly long ($wordCount words)');
    } else {
      earned += 1;
      details.add('Poor length ($wordCount words)');
    }

    if (!_atsUnfriendlyRegex.hasMatch(normalizedText)) {
      earned += 4;
      details.add('ATS-friendly format');
    } else {
      details.add('Possible tables/columns detected');
    }

    final uniqueChars = text.runes.toSet().length;
    if (uniqueChars > 40) {
      earned += 3;
      details.add('Parseable text');
    }

    final nonEmptyLines =
        text.split('\n').where((l) => l.trim().isNotEmpty).length;
    if (nonEmptyLines > 15) {
      earned += 3;
      details.add('Well-structured lines');
    }

    return SectionScore(
      label: 'Formatting & Parseability',
      earned: earned.clamp(0, maxScore).toDouble(),
      max: maxScore,
      detail: details.join(' | '),
    );
  }

  static SectionScore _scoreQuantifiedImpact(String text) {
    const maxScore = 10.0;
    final count = _quantifierRegex.allMatches(text).length;
    final earned = min(count / 6.0, 1.0) * maxScore;

    return SectionScore(
      label: 'Quantified Impact',
      earned: earned.clamp(0, maxScore).toDouble(),
      max: maxScore,
      detail: '$count quantified metrics found',
    );
  }

  static SectionScore _scoreActionVerbs(String text) {
    const maxScore = 8.0;
    final hits = _actionVerbs.where((v) => text.contains(v)).toList();
    final earned = min(hits.length / 8.0, 1.0) * maxScore;

    return SectionScore(
      label: 'Action Verbs',
      earned: earned.clamp(0, maxScore).toDouble(),
      max: maxScore,
      detail: '${hits.length} action verbs found',
    );
  }

  static SectionScore _scoreDates(String text) {
    const maxScore = 7.0;
    final count = _dateRegex.allMatches(text).length;
    final earned = min(count / 3.0, 1.0) * maxScore;

    return SectionScore(
      label: 'Dates & Consistency',
      earned: earned.clamp(0, maxScore).toDouble(),
      max: maxScore,
      detail: '$count date references found',
    );
  }

  static Set<String> _extractMeaningfulWords(String text) {
    const stopWords = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by',
      'from',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'have',
      'has',
      'had',
      'do',
      'does',
      'did',
      'will',
      'would',
      'could',
      'should',
      'may',
      'might',
      'shall',
      'can',
      'need',
    };

    return text
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3 && !stopWords.contains(w))
        .toSet();
  }

  static List<String> _generateSuggestions(Map<String, SectionScore> breakdown) {
    final suggestions = <String>[];

    if ((breakdown['keywordMatch']?.earned ?? 0) < 18) {
      suggestions
          .add('Add more industry-relevant technical and soft skill keywords.');
    }
    if ((breakdown['contactInfo']?.earned ?? 0) < 8) {
      suggestions.add('Ensure email, phone, and LinkedIn profile are present.');
    }
    if ((breakdown['sectionStructure']?.earned ?? 0) < 14) {
      suggestions
          .add('Include key sections: Summary, Experience, Education, Skills.');
    }
    if ((breakdown['formatting']?.earned ?? 0) < 10) {
      suggestions.add('Aim for 400-800 words and avoid complex tables/layouts.');
    }
    if ((breakdown['quantifiedImpact']?.earned ?? 0) < 6) {
      suggestions
          .add('Add measurable achievements, e.g., Increased conversion by 30%.');
    }
    if ((breakdown['actionVerbs']?.earned ?? 0) < 5) {
      suggestions
          .add('Start bullet points with action verbs like Led, Built, Improved.');
    }
    if ((breakdown['datesConsistency']?.earned ?? 0) < 4) {
      suggestions.add('Add clear date ranges in experience and education.');
    }

    if (suggestions.isEmpty) {
      suggestions.add('Great ATS readiness. Tailor keywords for each job post.');
    }

    return suggestions;
  }
}

class ATSResult {
  final int totalScore;
  final Map<String, SectionScore> breakdown;
  final int wordCount;
  final List<String> suggestions;

  const ATSResult({
    required this.totalScore,
    required this.breakdown,
    required this.wordCount,
    required this.suggestions,
  });

  factory ATSResult.empty() => const ATSResult(
        totalScore: 0,
        breakdown: {},
        wordCount: 0,
        suggestions: ['Could not extract text from the PDF.'],
      );

  String get grade {
    if (totalScore >= 85) return 'Excellent';
    if (totalScore >= 70) return 'Good';
    if (totalScore >= 50) return 'Fair';
    return 'Needs Work';
  }
}

class SectionScore {
  final String label;
  final double earned;
  final double max;
  final String detail;

  const SectionScore({
    required this.label,
    required this.earned,
    required this.max,
    required this.detail,
  });

  double get percentage => (earned / max * 100).clamp(0, 100).toDouble();
}