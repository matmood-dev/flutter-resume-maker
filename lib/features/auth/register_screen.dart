import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).register(
          _fullNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go('/home/dashboard');
    } else if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogo(),
                  const Gap(36),
                  _buildHeader(),
                  const Gap(28),
                  _buildFullNameField(),
                  const Gap(16),
                  _buildEmailField(),
                  const Gap(16),
                  _buildPhoneField(),
                  const Gap(16),
                  _buildPasswordField(),
                  const Gap(16),
                  _buildConfirmPasswordField(),
                  const Gap(24),
                  _buildRegisterButton(authState.isLoading),
                  const Gap(24),
                  _buildSocialDivider(),
                  const Gap(24),
                  _buildSocialButtons(),
                  const Gap(32),
                  _buildSignInLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 28,
          ),
        ),
        const Gap(12),
        Text(
          'ResumeAI',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.textWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Create Account',
          style: AppTextStyles.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        Text(
          'Start building your AI-powered resume',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      keyboardType: TextInputType.name,
      validator: Validators.validateName,
      textCapitalization: TextCapitalization.words,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Full name',
        prefixIcon: const Icon(
          Icons.person_outline,
          color: AppColors.textGrey,
        ),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Email address',
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: AppColors.textGrey,
        ),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          return Validators.validatePhone(value);
        }
        return null;
      },
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Phone number (optional)',
        prefixIcon: const Icon(
          Icons.phone_outlined,
          color: AppColors.textGrey,
        ),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: Validators.validatePassword,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.textGrey,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textGrey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      validator: _validateConfirmPassword,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Confirm password',
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.textGrey,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textGrey,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Create Account',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSocialDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.border, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textGrey,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.border, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            icon: Icons.g_mobiledata,
            label: 'Google',
            onPressed: () {},
          ),
        ),
        const Gap(16),
        Expanded(
          child: _SocialButton(
            icon: Icons.apple,
            label: 'Apple',
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textGrey,
          ),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            'Sign In',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: AppColors.textWhite,
          size: 24,
        ),
        label: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.card,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
