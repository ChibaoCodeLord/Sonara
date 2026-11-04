import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/gradient_button.dart';
import '../../../core/routes/app_router.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../services/auth_mock_service.dart';
import 'widgets/auth_step_indicator.dart';

/// SCR-03 (step 2): 6-digit email OTP with a 60s resend countdown.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _length = 6;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
      if (_controller.text.length == _length) _verify();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final cubit = context.read<AuthCubit>();
    if (cubit.state.isLoading) return;
    final ok = await cubit.verifyOtp(_controller.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.tastePicker,
        (_) => false,
        arguments: true,
      );
    } else {
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final code = _controller.text;
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                const AuthStepIndicator(step: 2),
                const SizedBox(height: 28),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Xác thực email',
                  style: AppTextStyles.headlineLg.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: 'Nhập mã 6 số vừa được gửi tới ',
                    children: [
                      TextSpan(
                        text: state.email.isEmpty ? 'email của bạn' : state.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textCharcoal,
                        ),
                      ),
                    ],
                  ),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => _focusNode.requestFocus(),
                  child: Stack(
                    children: [
                      // Hidden field captures input; the boxes mirror it.
                      Opacity(
                        opacity: 0,
                        child: SizedBox(
                          height: 56,
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            maxLength: _length,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < _length; i++) ...[
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCrisp,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: state.errorMessage != null
                                        ? const Color(0xFFBA1A1A)
                                        : i == code.length
                                            ? AppColors.primary
                                            : AppColors.borderMuted,
                                    width: i == code.length ? 1.8 : 1,
                                  ),
                                ),
                                child: Text(
                                  i < code.length ? code[i] : '',
                                  style: AppTextStyles.headlineMd,
                                ),
                              ),
                            ),
                            if (i < _length - 1) const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (state.errorMessage != null)
                  Text(
                    state.errorMessage!,
                    style: AppTextStyles.labelMd.copyWith(
                      color: const Color(0xFFBA1A1A),
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Chưa nhận được mã?', style: AppTextStyles.bodyMd),
                    TextButton(
                      onPressed: state.otpSecondsLeft > 0
                          ? null
                          : () => context.read<AuthCubit>().resendOtp(),
                      child: Text(
                        state.otpSecondsLeft > 0
                            ? 'Gửi lại sau ${state.otpSecondsLeft}s'
                            : 'Gửi lại mã',
                        style: AppTextStyles.labelLg.copyWith(
                          color: state.otpSecondsLeft > 0
                              ? AppColors.textMuted
                              : AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Môi trường demo: dùng mã ${AuthMockService.demoOtp}',
                          style: AppTextStyles.bodySm,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Xác nhận',
                  isLoading: state.isLoading,
                  onPressed: code.length == _length ? _verify : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
