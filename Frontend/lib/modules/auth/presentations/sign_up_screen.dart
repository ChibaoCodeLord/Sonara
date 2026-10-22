import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../common/widgets/gradient_button.dart';
import '../../../core/routes/app_router.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'widgets/auth_step_indicator.dart';
import 'widgets/password_strength_meter.dart';
import 'widgets/social_login_row.dart';

/// SCR-03 (step 1): Sign up form. Step 2 is [OtpVerificationScreen].
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _acceptedTerms = false;
  Map<String, String> _errors = const {};

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().clearError();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final errors = <String, String>{
      if (name.length < 2) 'name': 'Vui lòng nhập họ tên',
      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email))
        'email': 'Email không hợp lệ',
      if (PasswordStrengthMeter.scoreOf(password) < 2)
        'password': 'Mật khẩu cần ≥ 8 ký tự, có chữ hoa/thường hoặc số',
    };
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    final ok = await context.read<AuthCubit>().signUp(name, email, password);
    if (ok && mounted) {
      Navigator.of(context).pushNamed(AppRouter.otpVerification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                const AuthStepIndicator(step: 1),
                const SizedBox(height: 20),
                Text(
                  'Tạo tài khoản Sonara',
                  style: AppTextStyles.headlineLg.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Miễn phí 30 ngày Lossless và 50 lượt AI Hum mỗi tháng.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Họ và tên',
                  hint: 'Nguyễn Văn A',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  errorText: _errors['name'],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hint: 'ban@sonara.vn',
                  controller: _emailController,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  errorText: _errors['email'] ?? state.errorMessage,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Mật khẩu',
                  hint: 'Ít nhất 8 ký tự',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscure,
                  errorText: _errors['password'],
                  suffix: IconButton(
                    tooltip: _obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 10),
                PasswordStrengthMeter(password: _passwordController.text),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        activeColor: AppColors.primary,
                        onChanged: (v) =>
                            setState(() => _acceptedTerms = v ?? false),
                      ),
                      Expanded(
                        child: Text(
                          'Tôi đồng ý với Điều khoản dịch vụ và Chính sách quyền riêng tư',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Tiếp tục',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: state.isLoading,
                  onPressed: _acceptedTerms ? _submit : null,
                ),
                const SizedBox(height: 24),
                SocialLoginRow(
                  enabled: !state.isLoading,
                  onProviderTap: (provider) async {
                    final navigator = Navigator.of(context);
                    await context.read<AuthCubit>().signInWithProvider(provider);
                    navigator.pushNamedAndRemoveUntil(
                      AppRouter.tastePicker,
                      (_) => false,
                      arguments: true,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Đã có tài khoản?', style: AppTextStyles.bodyMd),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRouter.signIn),
                      child: Text(
                        'Đăng nhập',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
