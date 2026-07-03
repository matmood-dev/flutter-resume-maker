import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: Text('Privacy Policy', style: AppTextStyles.headlineMedium),
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
            title: '1. Information We Collect',
            content:
                'We collect information you provide directly, including your name, email address, phone number, resume content, and profile photo. We also collect usage data such as app features used and session duration.',
          ),
          _buildSection(
            title: '2. How We Use Your Information',
            content:
                'We use your information to provide and improve our services, generate AI-powered resume suggestions, store your resumes and cover letters, and communicate with you about your account.',
          ),
          _buildSection(
            title: '3. Data Storage',
            content:
                'Your data is stored securely using Supabase, a trusted cloud database provider. Resume data and profile information are encrypted in transit and at rest. Profile images are stored in Supabase Storage with access controls.',
          ),
          _buildSection(
            title: '4. AI Features',
            content:
                'Our AI features use your resume content to generate suggestions and improvements. This data is processed securely and is not used to train external AI models.',
          ),
          _buildSection(
            title: '5. Data Sharing',
            content:
                'We do not sell your personal information to third parties. We may share anonymized, aggregated data for analytics purposes. We may share information only when required by law.',
          ),
          _buildSection(
            title: '6. Data Retention',
            content:
                'We retain your data for as long as your account is active. You can delete your account at any time to remove your data from our servers.',
          ),
          _buildSection(
            title: '7. Security',
            content:
                'We implement industry-standard security measures to protect your personal information. However, no method of transmission over the Internet is 100% secure.',
          ),
          _buildSection(
            title: '8. Changes to This Policy',
            content:
                'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page with an updated revision date.',
          ),
          _buildSection(
            title: '9. Contact Us',
            content:
                'If you have any questions about this Privacy Policy, please contact us at matmood@outlook.com.',
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
