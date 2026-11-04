import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_bottom_sheet.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../common/widgets/gradient_button.dart';
import '../../../core/routes/app_navigator.dart';
import '../../../core/routes/app_router.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'widgets/auth_brand_mark.dart';
import 'widgets/social_login_row.dart';

/// SCR-02: Sign in.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().clearError();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static bool isValidEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    setState(() {
      _emailError = isValidEmail(email) ? null : 'Email không hợp lệ';
    });
    if (_emailError != null) return;
    final ok = await context
        .read<AuthCubit>()
        .signIn(email, _passwordController.text);
    if (ok && mounted) _goHome();
  }

  Future<void> _social(String provider) async {
    final ok = await context.read<AuthCubit>().signInWithProvider(provider);
    if (ok && mounted) _goHome();
  }

  void _goHome() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRouter.shell, (_) => false);
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
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AuthBrandMark(size: 36),
                ),
                const SizedBox(height: 24),
                Text(
                  'Chào mừng trở lại',
                  style: AppTextStyles.headlineLg.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Đăng nhập để đồng bộ thư viện, playlist và lịch sử AI Hum.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'Email hoặc tên đăng nhập',
                  hint: 'ban@sonara.vn',
                  controller: _emailController,
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Mật khẩu',
                  hint: 'Tối thiểu 6 ký tự',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _ForgotPasswordSheet.show(
                      context,
                      _emailController.text,
                    ),
                    child: Text(
                      'Quên mật khẩu?',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                if (state.errorMessage != null) ...[
                  _ErrorBanner(message: state.errorMessage!),
                  const SizedBox(height: 12),
                ],
                GradientButton(
                  label: 'Đăng nhập',
                  isLoading: state.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 28),
                SocialLoginRow(
                  enabled: !state.isLoading,
                  onProviderTap: _social,
                ),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Chưa có tài khoản?', style: AppTextStyles.bodyMd),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRouter.signUp),
                      child: Text(
                        'Đăng ký ngay',
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

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;

  const _ForgotPasswordSheet({required this.initialEmail});

  static Future<void> show(BuildContext context, String email) {
    return showAppBottomSheet<void>(
      context: context,
      title: 'Khôi phục mật khẩu',
      subtitle: 'Chúng tôi sẽ gửi liên kết đặt lại qua email',
      builder: (_) => _ForgotPasswordSheet(initialEmail: email),
    );
  }

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  late final _controller = TextEditingController(text: widget.initialEmail);
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Email đã đăng ký',
            hint: 'ban@sonara.vn',
            controller: _controller,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          GradientButton(
            label: 'Gửi liên kết đặt lại',
            isLoading: _sending,
            onPressed: () async {
              final email = _controller.text.trim();
              if (!_SignInScreenState.isValidEmail(email)) {
                AppNavigator.showMessage(context, 'Vui lòng nhập email hợp lệ');
                return;
              }
              setState(() => _sending = true);
              await context.read<AuthCubit>().requestPasswordReset(email);
              if (!context.mounted) return;
              AppNavigator.showMessage(context, 'Đã gửi liên kết tới $email');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
