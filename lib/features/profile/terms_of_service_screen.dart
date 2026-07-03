import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.textWhite),
        ),
        title: Text('Terms of Service', style: AppTextStyles.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          const Gap(8),
          Text(
            'Last updated: July 2026',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
          ),
          const Gap(24),
          _buildSection(
            title: '1. Acceptance of Terms',
            content:
                'By accessing or using ResumeAI, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
          ),
          _buildSection(
            title: '2. Description of Service',
            content:
                'ResumeAI is a mobile application that helps users create, manage, and optimize professional resumes using AI-powered tools. Features include resume building, template selection, ATS scoring, and cover letter generation.',
          ),
          _buildSection(
            title: '3. User Accounts',
            content:
                'You are responsible for maintaining the confidentiality of your account credentials. You agree to provide accurate and complete information when creating your account. You must be at least 16 years old to use this service.',
          ),
          _buildSection(
            title: '4. User Content',
            content:
                'You retain ownership of all content you create using ResumeAI, including resumes, cover letters, and profile information. By using our service, you grant us a limited license to store and process your content to provide the service.',
          ),
          _buildSection(
            title: '5. AI-Generated Content',
            content:
                'AI-powered suggestions and generated content are provided as drafts. You are responsible for reviewing and editing all content before using it in job applications. We do not guarantee the accuracy of AI-generated suggestions.',
          ),
          _buildSection(
            title: '6. Subscription and Payments',
            content:
                'Free features are available without a subscription. Paid subscriptions provide access to additional features. Payments are processed through the App Store or Google Play. You may cancel your subscription at any time.',
          ),
          _buildSection(
            title: '7. Prohibited Conduct',
            content:
                'You agree not to misuse the service, attempt to access other users\' accounts, use the service for illegal purposes, or attempt to reverse-engineer or copy the application.',
          ),
          _buildSection(
            title: '8. Termination',
            content:
                'We may suspend or terminate your account at any time for violation of these terms. You may delete your account at any time through the app settings.',
          ),
          _buildSection(
            title: '9. Limitation of Liability',
            content:
                'ResumeAI is provided "as is" without warranties of any kind. We are not liable for any damages arising from the use of our service, including but not limited to lost job opportunities or inaccurate resume content.',
          ),
          _buildSection(
            title: '10. Changes to Terms',
            content:
                'We reserve the right to modify these terms at any time. Continued use of the service after changes constitutes acceptance of the new terms.',
          ),
          _buildSection(
            title: '11. Contact',
            content:
                'For questions about these Terms of Service, please contact us at matmood@outlook.com.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleSmall),
          const Gap(8),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textGrey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
