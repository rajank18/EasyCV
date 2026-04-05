import 'package:flutter/material.dart';

class ResumeTemplateDefinition {
  final String id;
  final String name;
  final String role;
  final String description;
  final Color accent;
  final String fontFamily;

  const ResumeTemplateDefinition({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
    required this.accent,
    required this.fontFamily,
  });
}

const List<ResumeTemplateDefinition> kResumeTemplates = [
  ResumeTemplateDefinition(
    id: 'software_engineer_pro',
    name: 'Corporate Navy',
    role: 'Software Engineer',
    description: 'FAANG-style single-column resume with premium hierarchy.',
    accent: Color(0xFF1A3557),
    fontFamily: 'Roboto',
  ),
  ResumeTemplateDefinition(
    id: 'hr_people_ops',
    name: 'Executive Charcoal',
    role: 'HR',
    description: 'Formal consulting/finance layout with executive weight.',
    accent: Color(0xFF2D2D2D),
    fontFamily: 'Georgia',
  ),
  ResumeTemplateDefinition(
    id: 'data_science_insight',
    name: 'Modern Minimal',
    role: 'Data Science',
    description: 'Contemporary two-column layout for high-growth tech roles.',
    accent: Color(0xFF0073B1),
    fontFamily: 'Roboto',
  ),
  ResumeTemplateDefinition(
    id: 'architectural_grid',
    name: 'Architectural Resume',
    role: 'Product Design',
    description: 'Swiss-grid layout with vertical labels and geometric precision.',
    accent: Color(0xFF0D0D0D),
    fontFamily: 'Roboto',
  ),
  ResumeTemplateDefinition(
    id: 'executive_prestige',
    name: 'Executive Prestige',
    role: 'Leadership',
    description: 'Quiet luxury executive format with formal double-rule motif.',
    accent: Color(0xFF6B1D1D),
    fontFamily: 'Georgia',
  ),
  ResumeTemplateDefinition(
    id: 'creative_professional',
    name: 'Creative Professional',
    role: 'Engineering Lead',
    description: 'Single-column edge style with timeline borders and skill pills.',
    accent: Color(0xFF1B4332),
    fontFamily: 'Roboto',
  ),
];

ResumeTemplateDefinition getTemplateById(String id) {
  return kResumeTemplates.firstWhere(
    (t) => t.id == id,
    orElse: () => kResumeTemplates.first,
  );
}

Map<String, dynamic> buildRoleSampleProfile(String templateId) {
  if (templateId == 'architectural_grid') {
    return {
      'fullName': 'Ira Sen',
      'headline': 'Senior Product Designer',
      'email': 'ira.sen@email.com',
      'phone': '+91 98700 12345',
      'location': 'Bengaluru, India',
      'linkedIn': 'linkedin.com/in/irasen',
      'github': 'portfolio.irasen.com',
      'summary':
          'Senior product designer with 7+ years designing high-clarity enterprise workflows and consumer experiences. Specializes in systems thinking, interaction design, and measurable UX outcomes.',
      'skills':
          'Product Strategy, Interaction Design, User Research, Design Systems, Information Architecture, Prototyping, Accessibility, Figma',
      'certifications':
          'Google UX Design, Nielsen Norman UX Certification, Accessibility Core Competencies',
      'languages': 'English, Hindi',
      'experiences': [
        {
          'jobTitle': 'Lead Product Designer',
          'company': 'Notionary Labs',
          'duration': '2021 - Present',
          'description': 'Owned end-to-end design for collaboration and planning products.',
          'highlights': [
            'Redesigned onboarding architecture for core workspace flows, increasing activation by 34%',
            'Built a cross-platform design system that reduced UI inconsistencies by 62% across releases',
          ],
        },
        {
          'jobTitle': 'Senior UX Designer',
          'company': 'Airgrid Mobility',
          'duration': '2018 - 2021',
          'description': 'Led service design and experimentation in B2B mobility tools.',
          'highlights': [
            'Drove usability studies and iterative redesigns that reduced task completion time by 41%',
            'Partnered with engineering on tokenized component architecture, improving delivery speed by 28%',
          ],
        }
      ],
      'educations': [
        {
          'course': 'B.Des - Interaction Design',
          'university': 'National Institute of Design',
          'year': '2017',
          'grade': '8.8 CGPA',
        }
      ],
      'projects': [
        {
          'name': 'Enterprise Workflow Rebuild',
          'description': 'Re-architected IA and flow logic for procurement suite used by 10K+ users.',
          'technologies': 'Figma, FigJam, UserTesting',
          'link': 'portfolio.irasen.com/workflow',
        },
      ],
    };
  }

  if (templateId == 'executive_prestige') {
    return {
      'fullName': 'Arvind Malhotra',
      'headline': 'Vice President, Strategy & Operations',
      'email': 'arvind.m@email.com',
      'phone': '+91 98111 20304',
      'location': 'Mumbai, India',
      'linkedIn': 'linkedin.com/in/arvindmalhotra',
      'github': 'arvindmalhotra.com',
      'summary':
          'Executive leader with 12+ years across strategy, finance, and operations. Built high-performing business units, optimized P&L, and led transformation programs with measurable EBITDA impact.',
      'skills':
          'Corporate Strategy, P&L Ownership, M&A Integration, Financial Planning, Operational Excellence, Governance',
      'certifications':
          'Wharton Executive Leadership, Lean Six Sigma Black Belt, CFA Level II',
      'languages': 'English, Hindi',
      'experiences': [
        {
          'jobTitle': 'Vice President, Strategy & Operations',
          'company': 'Northbridge Capital Group',
          'duration': '2020 - Present',
          'description': 'Enterprise strategy and operating model transformation across business units.',
          'highlights': [
            'Led multi-market operating transformation, improving EBITDA margin by 11.4 percentage points',
            'Directed post-merger integration for 3 acquisitions, capturing synergies worth INR 48 Cr annually',
          ],
        },
        {
          'jobTitle': 'Director, Corporate Finance',
          'company': 'Aurelius Partners',
          'duration': '2015 - 2020',
          'description': 'Portfolio planning, investment governance, and board reporting.',
          'highlights': [
            'Built scenario planning model that improved capital allocation decisions across 9 portfolios',
            'Established governance cadence that reduced close-cycle reporting delays by 37%',
          ],
        }
      ],
      'educations': [
        {
          'course': 'MBA - Finance',
          'university': 'Indian School of Business',
          'year': '2014',
          'grade': 'Distinction',
        }
      ],
      'projects': [
        {
          'name': 'Operating Model Transformation',
          'description': 'Standardized governance, decision rights, and KPI architecture across geographies.',
          'technologies': 'Balanced Scorecard, Power BI, SAP',
          'link': '',
        }
      ],
    };
  }

  if (templateId == 'creative_professional') {
    return {
      'fullName': 'Devika Rao',
      'headline': 'Staff Software Engineer',
      'email': 'devika.rao@email.com',
      'phone': '+91 98989 45454',
      'location': 'Hyderabad, India',
      'linkedIn': 'linkedin.com/in/devikarao',
      'github': 'github.com/devikarao',
      'summary':
          'Staff engineer focused on platform reliability and developer productivity. Known for shipping resilient backend services, mentoring teams, and modernizing CI/CD systems at scale.',
      'skills':
          'Distributed Systems, Go, Dart, Flutter, Kubernetes, API Design, Observability, CI/CD, SRE',
      'certifications':
          'Google Professional Cloud Architect, CKAD, AWS Solutions Architect Associate',
      'languages': 'English, Telugu',
      'experiences': [
        {
          'jobTitle': 'Staff Software Engineer',
          'company': 'Streamline Labs',
          'duration': '2022 - Present',
          'description': 'Platform engineering and reliability leadership across product squads.',
          'highlights': [
            'Led architecture for event-driven billing services, reducing failed payments by 46%',
            'Introduced progressive delivery framework with SLO gates, improving release confidence by 3.2x',
          ],
        },
        {
          'jobTitle': 'Senior Software Engineer',
          'company': 'PulseStack',
          'duration': '2018 - 2022',
          'description': 'Backend and mobile platform development for fintech products.',
          'highlights': [
            'Built telemetry platform processing 150M+ events/day with 99.95% ingestion reliability',
            'Mentored 12 engineers and launched engineering playbooks that reduced incident MTTR by 39%',
          ],
        }
      ],
      'educations': [
        {
          'course': 'B.Tech - Computer Science',
          'university': 'BITS Pilani',
          'year': '2018',
          'grade': '8.9 CGPA',
        }
      ],
      'projects': [
        {
          'name': 'Resilience Engineering Toolkit',
          'description': 'Internal toolkit for chaos drills, SLO guardrails, and rollback automation.',
          'technologies': 'Go, Terraform, Grafana, GitHub Actions',
          'link': 'github.com/devikarao/resilience-kit',
        }
      ],
    };
  }

  if (templateId == 'hr_people_ops') {
    return {
      'fullName': 'Aarohi Mehta',
      'headline': 'Senior HR Business Partner',
      'email': 'aarohi.mehta@email.com',
      'phone': '+91 98765 43210',
      'location': 'Pune, India',
      'linkedIn': 'linkedin.com/in/aarohimehta',
      'github': 'portfolio.aarohimehta.com',
      'summary':
          'Strategic HR professional with 6+ years of experience scaling hiring pipelines, improving retention, and building high-trust people practices across tech teams.',
      'skills':
          'Talent Acquisition, Employee Relations, HR Analytics, Performance Management, HRBP, Policy Design, L&D',
      'certifications':
          'SHRM-CP, Certified Compensation Professional (CCP), Advanced HR Analytics',
      'languages': 'English, Hindi',
      'achievements':
          'Reduced time-to-hire by 38%, improved 12-month retention by 21%, and launched a mentorship program across 3 business units.',
      'interests': 'Employer Branding, DEI Programs, Leadership Coaching',
      'experiences': [
        {
          'jobTitle': 'Senior HR Business Partner',
          'company': 'BrightPath Technologies',
          'duration': '2021 - Present',
          'description': 'Business partnering and talent strategy for product teams.',
          'highlights': [
            'Led workforce planning for 4 departments, improving offer-to-join ratio by 27% in 3 quarters',
            'Implemented quarterly engagement diagnostics and manager coaching, raising retention by 21% year-over-year',
          ],
        },
        {
          'jobTitle': 'HR Generalist',
          'company': 'TalentBridge Solutions',
          'duration': '2018 - 2021',
          'description': 'End-to-end hiring and onboarding for growth teams.',
          'highlights': [
            'Owned recruitment for engineering and operations, reducing time-to-hire by 38%',
            'Introduced structured interview scorecards, improving hiring quality across 60+ roles',
          ],
        }
      ],
      'educations': [
        {
          'course': 'MBA - Human Resources',
          'university': 'Symbiosis Institute of Business Management',
          'year': '2018',
          'grade': '8.9 CGPA',
        }
      ],
      'projects': [
        {
          'name': 'Hiring Funnel Optimization',
          'description':
              'Redesigned recruiter workflow and panel calibration process to improve candidate conversion.',
          'technologies': 'Google Sheets, Looker Studio, ATS',
          'link': '',
        }
      ],
    };
  }

  if (templateId == 'data_science_insight') {
    return {
      'fullName': 'Rohan Banerjee',
      'headline': 'Data Scientist II',
      'email': 'rohan.banerjee@email.com',
      'phone': '+91 90909 12121',
      'location': 'Bengaluru, India',
      'linkedIn': 'linkedin.com/in/rohanbanerjee',
      'github': 'github.com/rohanbanerjee',
      'summary':
          'Data Scientist focused on predictive modeling and experimentation. Built ML systems used by product, growth, and risk teams to improve conversion and reduce churn.',
      'skills':
          'Python, SQL, PyTorch, Scikit-learn, Feature Engineering, A/B Testing, Tableau, Airflow',
      'certifications':
          'Google Advanced Data Analytics, AWS Machine Learning Specialty',
      'languages': 'English, Bengali, Hindi',
      'achievements':
          'Improved churn prediction AUC from 0.71 to 0.86 and shipped recommendation model that increased retention by 14%.',
      'interests': 'Causal Inference, Recommender Systems, Behavioral Analytics',
      'experiences': [
        {
          'jobTitle': 'Data Scientist II',
          'company': 'Neuron Labs',
          'duration': '2022 - Present',
          'description': 'Built production ML pipelines and experimentation frameworks.',
          'highlights': [
            'Architected real-time propensity models serving 2M+ daily predictions with stable latency under 120ms',
            'Automated model monitoring with drift alerts, cutting model incidents by 43%',
          ],
        },
        {
          'jobTitle': 'Data Analyst',
          'company': 'MetricWorks',
          'duration': '2019 - 2022',
          'description': 'Experimentation and analytics for growth operations.',
          'highlights': [
            'Designed A/B testing framework and dashboards used by growth leads across 6 funnels',
            'Analyzed campaign performance and improved paid conversion by 18% through segment optimization',
          ],
        }
      ],
      'educations': [
        {
          'course': 'B.Tech - Computer Science',
          'university': 'VIT University',
          'year': '2019',
          'grade': '9.1 CGPA',
        }
      ],
      'projects': [
        {
          'name': 'Subscription Churn Predictor',
          'description':
              'Gradient boosting model with SHAP insights for CRM interventions.',
          'technologies': 'Python, XGBoost, SHAP, FastAPI',
          'link': 'github.com/rohan/churn-predictor',
        },
        {
          'name': 'Recommendation Engine',
          'description':
              'Hybrid ranking model using collaborative + content-based signals.',
          'technologies': 'PyTorch, Redis, Docker',
          'link': '',
        }
      ],
    };
  }

  return {
    'fullName': 'Nikhil Arora',
    'headline': 'Senior Software Engineer',
    'email': 'nikhil.arora@email.com',
    'phone': '+91 91234 56789',
    'location': 'Hyderabad, India',
    'linkedIn': 'linkedin.com/in/nikhilarora',
    'github': 'github.com/nikhilarora',
    'summary':
        'Software Engineer with 5+ years building production Flutter and backend systems. Experienced in shipping scalable products, developer tooling, and high-quality user experiences.',
    'skills':
        'Flutter, Dart, Firebase, REST APIs, Node.js, PostgreSQL, CI/CD, GitHub Actions, Clean Architecture',
    'certifications':
        'Google Associate Android Developer, AWS Certified Developer Associate',
    'languages': 'English, Hindi, Telugu',
    'achievements':
        'Reduced crash-free sessions by 42%, improved app startup time by 31%, and led migration to modular architecture.',
    'interests': 'Mobile Performance, DX Automation, System Design',
    'experiences': [
      {
        'jobTitle': 'Senior Software Engineer',
        'company': 'BuildMint',
        'duration': '2021 - Present',
        'description': 'Platform architecture and feature delivery across mobile products.',
        'highlights': [
          'Led cross-functional team of 8 engineers to deliver payment microservice, reducing transaction latency by 40%',
          'Architected REST API handling 2M+ daily requests with 99.9% uptime and automated rollback safeguards',
        ],
      },
      {
        'jobTitle': 'Software Engineer',
        'company': 'CodeOrbit',
        'duration': '2019 - 2021',
        'description': 'Backend integrations and release automation.',
        'highlights': [
          'Implemented authentication and profile services, reducing onboarding failures by 33%',
          'Built CI pipelines that cut release cycle time from 3 days to 6 hours',
        ],
      }
    ],
    'educations': [
      {
        'course': 'B.Tech - Information Technology',
        'university': 'JNTU Hyderabad',
        'year': '2019',
        'grade': '8.7 CGPA',
      }
    ],
    'projects': [
      {
        'name': 'EasyCV Mobile Platform',
        'description':
            'Resume builder with authentication, ATS scoring, and template-driven PDF generation.',
        'technologies': 'Flutter, Firebase, Cloud Functions',
        'link': 'github.com/nikhil/easycv',
      },
      {
        'name': 'Realtime Chat SDK',
        'description':
            'Socket-based SDK for low-latency messaging and offline sync.',
        'technologies': 'Dart, WebSocket, SQLite',
        'link': '',
      }
    ],
  };
}

Map<String, dynamic> mergeProfileData(
  Map<String, dynamic> sample,
  Map<String, dynamic> profile,
) {
  final merged = Map<String, dynamic>.from(sample);

  for (final entry in profile.entries) {
    final value = entry.value;
    if (value == null) {
      continue;
    }
    if (value is String && value.trim().isEmpty) {
      continue;
    }
    if (value is List && value.isEmpty) {
      continue;
    }
    merged[entry.key] = value;
  }

  return merged;
}
