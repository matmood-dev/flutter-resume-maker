import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

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
        title: Text('Help Center', style: AppTextStyles.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          const Gap(8),
          Text(
            'Frequently Asked Questions',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
          const Gap(24),
          _buildFAQ(
            question: 'How do I create a resume?',
            answer:
                'Tap the "Create Resume" button on the dashboard or resumes tab. Fill in your details across the 9 steps — personal info, summary, education, experience, skills, projects, certificates, and languages. Then choose a template and download your PDF.',
          ),
          _buildFAQ(
            question: 'What is ATS and why does it matter?',
            answer:
                'ATS (Applicant Tracking System) is software used by employers to scan resumes. Our ATS-friendly templates are optimized to pass these systems, ensuring your resume gets seen by hiring managers.',
          ),
          _buildFAQ(
            question: 'Can I use AI to help write my resume?',
            answer:
                'Yes! We offer AI-powered suggestions for your professional summary, skills, and experience descriptions. You can find the AI buttons throughout the resume builder.',
          ),
          _buildFAQ(
            question: 'How do I edit an existing resume?',
            answer:
                'Go to the Resumes tab and tap on the resume you want to edit. All your data will be pre-filled in the builder. Make your changes and tap Finish to save.',
          ),
          _buildFAQ(
            question: 'Can I change my profile photo?',
            answer:
                'Yes! Go to Profile and tap the camera icon on your avatar. You can choose to take a photo or pick one from your gallery.',
          ),
          _buildFAQ(
            question: 'How do I change my password?',
            answer:
                'Go to Profile → Security → Change Password. Enter your current password and new password, then tap Update Password.',
          ),
          _buildFAQ(
            question: 'What subscription plans are available?',
            answer:
                'We offer Free, Basic (3 BD/month), Premium (7 BD/month), and Enterprise (19 BD/month) plans. Each plan includes different limits on resumes, AI credits, and features.',
          ),
          _buildFAQ(
            question: 'How do I delete my account?',
            answer:
                'Account deletion is coming soon. If you need to remove your data, please contact our support team.',
          ),
          const Gap(24),
          Text(
            'Still need help?',
            style: AppTextStyles.titleMedium,
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.email_outlined, color: AppColors.primary),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact Support', style: AppTextStyles.bodyMedium),
                      Text(
                        'matmood@outlook.com',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textGrey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textGrey,
          title: Text(
            question,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            Text(
              answer,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textGrey,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
