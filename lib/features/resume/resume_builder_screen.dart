import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/education_model.dart';
import '../../models/experience_model.dart';
import '../../models/project_model.dart';
import '../../models/certificate_model.dart';
import '../../models/resume_model.dart';
import '../../providers/resume_provider.dart';

class ResumeBuilderScreen extends ConsumerStatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  ConsumerState<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends ConsumerState<ResumeBuilderScreen> {
  int _currentStep = 0;
  late final PageController _pageController;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();

  final _summaryController = TextEditingController();

  final List<Education> _educationList = [];
  final _schoolController = TextEditingController();
  final _degreeController = TextEditingController();
  final _majorController = TextEditingController();
  final _gpaController = TextEditingController();
  DateTime _graduationDate = DateTime.now();

  final List<Experience> _experienceList = [];
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  DateTime _expStartDate = DateTime.now();
  DateTime? _expEndDate;

  final List<String> _skills = [];
  final _skillController = TextEditingController();

  final List<Project> _projectList = [];
  final _projectNameController = TextEditingController();
  final _projectDescController = TextEditingController();
  final _projectTechController = TextEditingController();
  final _projectLinkController = TextEditingController();

  final List<Certificate> _certificateList = [];
  final _certNameController = TextEditingController();
  final _certOrgController = TextEditingController();
  DateTime _certDate = DateTime.now();

  final List<String> _languages = [];
  final _languageController = TextEditingController();

  static const _stepLabels = [
    'Personal',
    'Summary',
    'Education',
    'Experience',
    'Skills',
    'Projects',
    'Certificates',
    'Languages',
    'Preview',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _summaryController.dispose();
    _schoolController.dispose();
    _degreeController.dispose();
    _majorController.dispose();
    _gpaController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _responsibilitiesController.dispose();
    _skillController.dispose();
    _projectNameController.dispose();
    _projectDescController.dispose();
    _projectTechController.dispose();
    _projectLinkController.dispose();
    _certNameController.dispose();
    _certOrgController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepLabels.length - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveResume() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final resume = ResumeModel(
        userId: user.id,
        title: _nameController.text.isNotEmpty
            ? '${_nameController.text}\'s Resume'
            : 'Untitled Resume',
        personalInfo: PersonalInfo(
          fullName: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          linkedIn: _linkedinController.text,
          portfolioUrl: _portfolioController.text,
        ),
        summary: _summaryController.text,
        education: _educationList,
        experience: _experienceList,
        skills: _skills,
        projects: _projectList,
        certificates: _certificateList,
        languages: _languages,
      );

      await ref.read(resumeProvider.notifier).addResume(resume);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume saved! Choose a template to generate PDF.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.push('/resume/template-selection', extra: resume);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving resume: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDatePicker(ValueChanged<DateTime> onPicked) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.card,
              onSurface: AppColors.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) onPicked(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
        ),
        title: Text('Resume Builder', style: AppTextStyles.headlineMedium),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          const Gap(16),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoStep(),
                _buildSummaryStep(),
                _buildEducationStep(),
                _buildExperienceStep(),
                _buildSkillsStep(),
                _buildProjectsStep(),
                _buildCertificatesStep(),
                _buildLanguagesStep(),
                _buildPreviewStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _stepLabels.length,
        itemBuilder: (context, index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Container(
            width: 64,
            margin: const EdgeInsets.only(right: 4),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.card,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(77),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check,
                            color: AppColors.background, size: 18)
                        : Text(
                            '${index + 1}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isCurrent
                                  ? AppColors.background
                                  : AppColors.textGrey,
                            ),
                          ),
                  ),
                ),
                const Gap(6),
                Text(
                  _stepLabels[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.textGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
    Widget? prefix,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
          prefixIcon: prefix,
          suffixIcon: suffix,
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildAIButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStepSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: AppTextStyles.headlineSmall),
    );
  }

  Widget _buildPersonalInfoStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildStepSection('Personal Information'),
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          prefix: const Icon(Icons.person_outline, color: AppColors.textGrey),
        ),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          prefix: const Icon(Icons.email_outlined, color: AppColors.textGrey),
        ),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone',
          keyboardType: TextInputType.phone,
          prefix:
              const Icon(Icons.phone_outlined, color: AppColors.textGrey),
        ),
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          prefix: const Icon(Icons.location_on_outlined,
              color: AppColors.textGrey),
        ),
        _buildTextField(
          controller: _linkedinController,
          label: 'LinkedIn',
          prefix:
              const Icon(Icons.link, color: AppColors.textGrey),
        ),
        _buildTextField(
          controller: _githubController,
          label: 'GitHub',
          prefix: const Icon(Icons.code, color: AppColors.textGrey),
        ),
        _buildTextField(
          controller: _portfolioController,
          label: 'Portfolio URL',
          prefix:
              const Icon(Icons.language, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildSummaryStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildStepSection('Professional Summary'),
        _buildTextField(
          controller: _summaryController,
          label: 'Summary',
          maxLines: 6,
          hint: 'Write a compelling professional summary...',
        ),
        const Gap(16),
        _buildAIButton(
          label: 'Generate with AI',
          icon: Icons.auto_awesome,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildEducationStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildStepSection('Education'),
        ..._educationList.asMap().entries.map((entry) {
          final edu = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(edu.school, style: AppTextStyles.titleSmall),
                      const Gap(4),
                      Text(
                        '${edu.degree} in ${edu.major}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _educationList.removeAt(entry.key)),
                  icon: const Icon(Icons.close,
                      color: AppColors.textGrey, size: 20),
                ),
              ],
            ),
          );
        }),
        _buildTextField(controller: _schoolController, label: 'School'),
        _buildTextField(controller: _degreeController, label: 'Degree'),
        _buildTextField(controller: _majorController, label: 'Major'),
        _buildTextField(
          controller: _gpaController,
          label: 'GPA (optional)',
          keyboardType: TextInputType.number,
        ),
        _buildDateField(
          label: 'Graduation Date',
          date: _graduationDate,
          onPicked: (d) => setState(() => _graduationDate = d),
        ),
        const Gap(12),
        OutlinedButton.icon(
          onPressed: () {
            if (_schoolController.text.isNotEmpty &&
                _degreeController.text.isNotEmpty &&
                _majorController.text.isNotEmpty) {
              setState(() {
                _educationList.add(Education(
                  school: _schoolController.text,
                  degree: _degreeController.text,
                  major: _majorController.text,
                  gpa: double.tryParse(_gpaController.text),
                  graduationDate: _graduationDate,
                ));
                _schoolController.clear();
                _degreeController.clear();
                _majorController.clear();
                _gpaController.clear();
              });
            }
          },
          icon: const Icon(Icons.add, color: AppColors.primary),
          label: const Text('Add More'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildStepSection('Work Experience'),
        ..._experienceList.asMap().entries.map((entry) {
          final exp = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exp.position, style: AppTextStyles.titleSmall),
                      const Gap(4),
                      Text(
                        exp.company,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _experienceList.removeAt(entry.key)),
                  icon: const Icon(Icons.close,
                      color: AppColors.textGrey, size: 20),
                ),
              ],
            ),
          );
        }),
        _buildTextField(controller: _companyController, label: 'Company'),
        _buildTextField(controller: _positionController, label: 'Position'),
        _buildDateField(
          label: 'Start Date',
          date: _expStartDate,
          onPicked: (d) => setState(() => _expStartDate = d),
        ),
        _buildDateField(
          label: 'End Date (optional)',
          date: _expEndDate,
          onPicked: (d) => setState(() => _expEndDate = d),
          optional: true,
        ),
        _buildTextField(
          controller: _responsibilitiesController,
          label: 'Responsibilities',
          maxLines: 4,
          hint: 'Describe your responsibilities...',
        ),
        const Gap(12),
        _buildAIButton(
          label: 'Improve with AI',
          icon: Icons.auto_awesome,
          onPressed: () {},
        ),
        const Gap(12),
        OutlinedButton.icon(
          onPressed: () {
            if (_companyController.text.isNotEmpty &&
                _positionController.text.isNotEmpty) {
              setState(() {
                _experienceList.add(Experience(
                  company: _companyController.text,
                  position: _positionController.text,
                  startDate: _expStartDate,
                  endDate: _expEndDate,
                  responsibilities: _responsibilitiesController.text
                      .split('\n')
                      .where((s) => s.trim().isNotEmpty)
                      .toList(),
                ));
                _companyController.clear();
                _positionController.clear();
                _responsibilitiesController.clear();
              });
            }
          },
          icon: const Icon(Icons.add, color: AppColors.primary),
          label: const Text('Add More'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildStepSection('Skills'),
        if (_skills.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((skill) {
              return Chip(
                label: Text(skill, style: AppTextStyles.labelMedium),
                backgroundColor: AppColors.primary.withAlpha(38),
                labelStyle: const TextStyle(color: AppColors.primary),
                deleteIcon:
                    const Icon(Icons.close, size: 16, color: AppColors.primary),
                onDeleted: () => setState(() => _skills.remove(skill)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
          const Gap(16),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Add a skill...',
                  hintStyle: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textGrey),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      _skills.add(value.trim());
                      _skillController.clear();
                    });
                  }
                },
              ),
            ),
            const Gap(8),
            IconButton(
              onPressed: () {
                if (_skillController.text.trim().isNotEmpty) {
                  setState(() {
                    _skills.add(_skillController.text.trim());
                    _skillController.clear();
                  });
                }
              },
              icon: const Icon(Icons.add_circle,
                  color: AppColors.primary, size: 32),
            ),
          ],
        ),
        const Gap(16),
        _buildAIButton(
          label: 'Suggest Skills',
          icon: Icons.auto_awesome,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProjectsStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildStepSection('Projects'),
        ..._projectList.asMap().entries.map((entry) {
          final proj = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(proj.name, style: AppTextStyles.titleSmall),
                      const Gap(4),
                      Text(
                        proj.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _projectList.removeAt(entry.key)),
                  icon: const Icon(Icons.close,
                      color: AppColors.textGrey, size: 20),
                ),
              ],
            ),
          );
        }),
        _buildTextField(controller: _projectNameController, label: 'Project Name'),
        _buildTextField(
          controller: _projectDescController,
          label: 'Description',
          maxLines: 3,
        ),
        _buildTextField(
          controller: _projectTechController,
          label: 'Technologies (comma-separated)',
        ),
        _buildTextField(
          controller: _projectLinkController,
          label: 'GitHub Link',
          prefix: const Icon(Icons.code, color: AppColors.textGrey),
        ),
        const Gap(12),
        _buildAIButton(
          label: 'Rewrite with AI',
          icon: Icons.auto_awesome,
          onPressed: () {},
        ),
        const Gap(12),
        OutlinedButton.icon(
          onPressed: () {
            if (_projectNameController.text.isNotEmpty &&
                _projectDescController.text.isNotEmpty) {
              setState(() {
                _projectList.add(Project(
                  name: _projectNameController.text,
                  description: _projectDescController.text,
                  technologies: _projectTechController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                  githubLink: _projectLinkController.text.isNotEmpty
                      ? _projectLinkController.text
                      : null,
                ));
                _projectNameController.clear();
                _projectDescController.clear();
                _projectTechController.clear();
                _projectLinkController.clear();
              });
            }
          },
          icon: const Icon(Icons.add, color: AppColors.primary),
          label: const Text('Add More'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificatesStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildStepSection('Certificates'),
        ..._certificateList.asMap().entries.map((entry) {
          final cert = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cert.name, style: AppTextStyles.titleSmall),
                      const Gap(4),
                      Text(
                        '${cert.organization} · ${DateFormat('MMM yyyy').format(cert.date)}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _certificateList.removeAt(entry.key)),
                  icon: const Icon(Icons.close,
                      color: AppColors.textGrey, size: 20),
                ),
              ],
            ),
          );
        }),
        _buildTextField(
          controller: _certNameController,
          label: 'Certificate Name',
        ),
        _buildTextField(
          controller: _certOrgController,
          label: 'Organization',
        ),
        _buildDateField(
          label: 'Date',
          date: _certDate,
          onPicked: (d) => setState(() => _certDate = d),
        ),
        const Gap(12),
        OutlinedButton.icon(
          onPressed: () {
            if (_certNameController.text.isNotEmpty &&
                _certOrgController.text.isNotEmpty) {
              setState(() {
                _certificateList.add(Certificate(
                  name: _certNameController.text,
                  organization: _certOrgController.text,
                  date: _certDate,
                ));
                _certNameController.clear();
                _certOrgController.clear();
              });
            }
          },
          icon: const Icon(Icons.add, color: AppColors.primary),
          label: const Text('Add More'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguagesStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildStepSection('Languages'),
        if (_languages.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _languages.map((lang) {
              return Chip(
                label: Text(lang, style: AppTextStyles.labelMedium),
                backgroundColor: AppColors.primary.withAlpha(38),
                labelStyle: const TextStyle(color: AppColors.primary),
                deleteIcon: const Icon(Icons.close,
                    size: 16, color: AppColors.primary),
                onDeleted: () => setState(() => _languages.remove(lang)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
          const Gap(16),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _languageController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Add a language...',
                  hintStyle: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textGrey),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      _languages.add(value.trim());
                      _languageController.clear();
                    });
                  }
                },
              ),
            ),
            const Gap(8),
            IconButton(
              onPressed: () {
                if (_languageController.text.trim().isNotEmpty) {
                  setState(() {
                    _languages.add(_languageController.text.trim());
                    _languageController.clear();
                  });
                }
              },
              icon: const Icon(Icons.add_circle,
                  color: AppColors.primary, size: 32),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildStepSection('Resume Preview'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_nameController.text.isNotEmpty)
                Text(_nameController.text,
                    style: AppTextStyles.headlineMedium),
              const Gap(8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  if (_emailController.text.isNotEmpty)
                    Text(_emailController.text,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textGrey)),
                  if (_phoneController.text.isNotEmpty)
                    Text(_phoneController.text,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textGrey)),
                  if (_addressController.text.isNotEmpty)
                    Text(_addressController.text,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textGrey)),
                ],
              ),
              if (_summaryController.text.isNotEmpty) ...[
                const Gap(20),
                Text('Summary', style: AppTextStyles.titleSmall),
                const Gap(8),
                Text(_summaryController.text,
                    style: AppTextStyles.bodyMedium),
              ],
              if (_educationList.isNotEmpty) ...[
                const Gap(20),
                Text('Education', style: AppTextStyles.titleSmall),
                const Gap(8),
                ..._educationList.map((edu) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(edu.school,
                              style: AppTextStyles.bodyMedium),
                          Text(
                            '${edu.degree} in ${edu.major}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    )),
              ],
              if (_experienceList.isNotEmpty) ...[
                const Gap(20),
                Text('Experience', style: AppTextStyles.titleSmall),
                const Gap(8),
                ..._experienceList.map((exp) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exp.position,
                              style: AppTextStyles.bodyMedium),
                          Text(exp.company,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textGrey)),
                        ],
                      ),
                    )),
              ],
              if (_skills.isNotEmpty) ...[
                const Gap(20),
                Text('Skills', style: AppTextStyles.titleSmall),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills
                      .map((s) => Chip(
                            label: Text(s,
                                style: AppTextStyles.labelSmall),
                            backgroundColor:
                                AppColors.primary.withAlpha(38),
                            labelStyle: const TextStyle(
                                color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide.none,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPicked,
    bool optional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _showDatePicker(onPicked),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textGrey),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: const Icon(Icons.calendar_today,
                color: AppColors.textGrey, size: 20),
          ),
          child: Text(
            date == null
                ? (optional ? 'Select date' : 'Pick a date')
                : DateFormat('MMM d, yyyy').format(date),
            style: AppTextStyles.bodyMedium.copyWith(
              color: date == null ? AppColors.textGrey : AppColors.textWhite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const Gap(12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _currentStep == _stepLabels.length - 1
                    ? _saveResume
                    : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.background,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: AppColors.textGrey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentStep == _stepLabels.length - 1 ? 'Finish' : 'Next',
                  style: AppTextStyles.buttonMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
