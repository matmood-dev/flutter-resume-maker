import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, ref, user)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('Account'),
                const Gap(12),
                _buildSettingsGroup([
                  _buildSettingsTile(
                    icon: Icons.person_outline,
                    title: 'Personal Info',
                    onTap: () => _showPersonalInfoSheet(context, ref, user),
                  ),
                  _buildSettingsTile(
                    icon: Icons.card_membership_outlined,
                    title: 'Subscription',
                    badge: _getSubscriptionLabel(user?.subscriptionTier),
                    badgeColor: AppColors.primary,
                    onTap: () => context.push('/subscription'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Security',
                    onTap: () => context.push('/security'),
                  ),
                ]),
                const Gap(24),
                _buildSectionTitle('Preferences'),
                const Gap(12),
                _buildSettingsGroup([
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    trailing: Text(
                      'English',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textGrey),
                    ),
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Theme',
                    trailing: Switch(
                      value: themeState.isDark,
                      onChanged: (_) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withAlpha(80),
                      inactiveThumbColor: AppColors.textGrey,
                      inactiveTrackColor: AppColors.card,
                    ),
                    onTap: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withAlpha(80),
                      inactiveThumbColor: AppColors.textGrey,
                      inactiveTrackColor: AppColors.card,
                    ),
                    onTap: () {},
                    showDivider: false,
                  ),
                ]),
                const Gap(24),
                _buildSectionTitle('Support'),
                const Gap(12),
                _buildSettingsGroup([
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {},
                    showDivider: false,
                  ),
                ]),
                const Gap(24),
                _buildSectionTitle('About'),
                const Gap(12),
                _buildSettingsGroup([
                  _buildSettingsTile(
                    icon: Icons.star_outline,
                    title: 'Rate App',
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    icon: Icons.share_outlined,
                    title: 'Share App',
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    trailing: Text(
                      '1.0.0',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textGrey),
                    ),
                    onTap: () {},
                    showDivider: false,
                  ),
                ]),
                const Gap(32),
                _buildLogoutButton(context, ref),
                const Gap(16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, dynamic user) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text('Profile', style: AppTextStyles.titleLarge),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 22),
                  onPressed: () {},
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),
          const Gap(12),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(38),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: user?.profileImage != null && user!.profileImage!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          user.profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            size: 44,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 44,
                        color: AppColors.primary,
                      ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 14,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () => _showImageSourceSheet(context, ref),
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            user?.fullName ?? 'Guest',
            style: AppTextStyles.headlineMedium,
          ),
          const Gap(4),
          Text(
            user?.phoneNumber?.isNotEmpty == true
                ? user!.phoneNumber
                : 'No phone number',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleMedium);
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    String? badge,
    Color? badgeColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textWhite),
                const Gap(12),
                Expanded(
                  child: Row(
                    children: [
                      Text(title, style: AppTextStyles.bodyMedium),
                      if (badge != null) ...[
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? AppColors.primary).withAlpha(38),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: badgeColor ?? AppColors.primary,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing
                else
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textGrey,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.border,
            indent: 52,
          ),
      ],
    );
  }

  String _getSubscriptionLabel(dynamic tier) {
    if (tier == null) return 'Free';
    final name = tier.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  void _showPersonalInfoSheet(
      BuildContext context, WidgetRef ref, dynamic user) {
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Personal Info', style: AppTextStyles.titleLarge),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _buildSheetField(
                        controller: nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),
                      const Gap(16),
                      _buildSheetField(
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const Gap(32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                await ref
                                    .read(authProvider.notifier)
                                    .updateProfile(
                                      fullName: nameController.text.trim(),
                                      phoneNumber: phoneController.text.trim(),
                                    );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profile updated!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Save Changes',
                              style: AppTextStyles.buttonMedium
                                  .copyWith(color: AppColors.background),
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: AppTextStyles.bodyMedium.copyWith(
        color: enabled ? AppColors.textWhite : AppColors.textGrey,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(20),
              Text('Change Profile Photo', style: AppTextStyles.titleMedium),
              const Gap(20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text('Camera', style: AppTextStyles.bodyMedium),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    final ext = image.name.split('.').last;
                    await ref
                        .read(authProvider.notifier)
                        .uploadProfileImage(bytes, ext);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: Text('Gallery', style: AppTextStyles.bodyMedium),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    final ext = image.name.split('.').last;
                    await ref
                        .read(authProvider.notifier)
                        .uploadProfileImage(bytes, ext);
                  }
                },
            ),
            const Gap(16),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Text('Logout', style: AppTextStyles.titleLarge),
            content: Text(
              'Are you sure you want to logout?',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textGrey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Logout',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          await ref.read(authProvider.notifier).logout();
        }
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.error),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout, size: 20, color: AppColors.error),
          const Gap(8),
          Text(
            'Logout',
            style: AppTextStyles.buttonMedium.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
