import 'package:flutter/material.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  static const routeName = '/template-selection';

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Software Engineer',
    'Data Science',
    'HR',
    'Marketing',
    'Design',
    'Business',
    'Healthcare',
  ];

  final List<Map<String, dynamic>> _templates = [
    {
      'id': 'modern-se-1',
      'name': 'Modern Tech',
      'category': 'Software Engineer',
      'image': 'assets/templates/modern_tech.png',
      'description': 'Clean and modern design for tech professionals',
    },
    {
      'id': 'minimal-se-1',
      'name': 'Minimal Code',
      'category': 'Software Engineer',
      'image': 'assets/templates/minimal_code.png',
      'description': 'Minimalist design focused on your code skills',
    },
    {
      'id': 'data-1',
      'name': 'Data Analyst Pro',
      'category': 'Data Science',
      'image': 'assets/templates/data_analyst.png',
      'description': 'Perfect for data scientists and analysts',
    },
    {
      'id': 'hr-1',
      'name': 'HR Professional',
      'category': 'HR',
      'image': 'assets/templates/hr_pro.png',
      'description': 'Professional design for HR roles',
    },
    {
      'id': 'marketing-1',
      'name': 'Creative Marketing',
      'category': 'Marketing',
      'image': 'assets/templates/creative_marketing.png',
      'description': 'Bold design for marketing professionals',
    },
    {
      'id': 'design-1',
      'name': 'Designer Portfolio',
      'category': 'Design',
      'image': 'assets/templates/designer.png',
      'description': 'Showcase your design skills',
    },
    {
      'id': 'business-1',
      'name': 'Executive',
      'category': 'Business',
      'image': 'assets/templates/executive.png',
      'description': 'Professional design for business roles',
    },
    {
      'id': 'healthcare-1',
      'name': 'Medical Professional',
      'category': 'Healthcare',
      'image': 'assets/templates/medical.png',
      'description': 'Clean design for healthcare professionals',
    },
  ];

  List<Map<String, dynamic>> get _filteredTemplates {
    if (_selectedCategory == 'All') {
      return _templates;
    }
    return _templates.where((t) => t['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'Choose Template',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFF0e5bbc),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                );
              },
            ),
          ),
          
          // Templates Grid
          Expanded(
            child: _filteredTemplates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No templates found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _filteredTemplates[index];
                      return _TemplateCard(
                        name: template['name'],
                        category: template['category'],
                        image: template['image'],
                        description: template['description'],
                        onTap: () {
                          // Navigate to resume builder with this template
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected: ${template['name']}'),
                              backgroundColor: const Color(0xFF0e5bbc),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Template Card Widget
class _TemplateCard extends StatelessWidget {
  final String name;
  final String category;
  final String image;
  final String description;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.name,
    required this.category,
    required this.image,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template Preview Image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Placeholder when image is not available
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Preview',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Template Info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0e5bbc).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0e5bbc),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
