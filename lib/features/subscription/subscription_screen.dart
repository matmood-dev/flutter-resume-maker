import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentTier = user?.subscriptionTier;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
        ),
        title: Text('Subscription', style: AppTextStyles.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const Gap(8),
          Text(
            'Choose the plan that works for you',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
          const Gap(24),
          _buildPlanCard(
            context,
            name: 'Free',
            price: '0 BD',
            period: 'forever',
            features: [
              '3 resumes per month',
              '10 AI credits',
              'Basic templates',
              'PDF export',
            ],
            isActive: currentTier?.name == 'free',
            gradient: null,
            onTap: () {},
          ),
          const Gap(16),
          _buildPlanCard(
            context,
            name: 'Basic',
            price: '3 BD',
            period: '/month',
            features: [
              '10 resumes per month',
              '50 AI credits',
              'All templates',
              'PDF export',
              'Cover letter generator',
              'Priority support',
            ],
            isActive: currentTier?.name == 'basic',
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF5BA8E0)],
            ),
            onTap: () {},
          ),
          const Gap(16),
          _buildPlanCard(
            context,
            name: 'Premium',
            price: '7 BD',
            period: '/month',
            badge: 'BEST VALUE',
            features: [
              'Unlimited resumes',
              'Unlimited AI credits',
              'All templates',
              'PDF export',
              'Cover letter generator',
              'Resume scanning & ATS score',
              'Priority support',
              'Custom branding',
            ],
            isActive: currentTier?.name == 'premium',
            gradient: const LinearGradient(
              colors: [AppColors.accent, Color(0xFF6DD5FA)],
            ),
            onTap: () {},
          ),
          const Gap(16),
          _buildPlanCard(
            context,
            name: 'Enterprise',
            price: '19 BD',
            period: '/month',
            features: [
              'Everything in Premium',
              'Team collaboration',
              'Bulk resume generation',
              'API access',
              'Dedicated account manager',
              'Custom integrations',
            ],
            isActive: currentTier?.name == 'enterprise',
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
            ),
            onTap: () {},
          ),
          const Gap(32),
          Text(
            'All plans include a 7-day free trial. Cancel anytime.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
          const Gap(40),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String name,
    required String price,
    required String period,
    required List<String> features,
    required bool isActive,
    required LinearGradient? gradient,
    required VoidCallback onTap,
    String? badge,
  }) {
    final isCurrentPlan = isActive;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: isCurrentPlan
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (gradient != null)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        name[0],
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        name[0],
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: AppTextStyles.titleMedium),
                          if (badge != null) ...[
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Gap(2),
                      if (isCurrentPlan)
                        Text(
                          'Current Plan',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      period,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(16),
            Divider(color: AppColors.border, height: 1),
            const Gap(16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: gradient != null
                            ? AppColors.primary
                            : AppColors.textGrey,
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const Gap(8),
            if (!isCurrentPlan)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: gradient != null
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Get Started',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Current Plan',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
