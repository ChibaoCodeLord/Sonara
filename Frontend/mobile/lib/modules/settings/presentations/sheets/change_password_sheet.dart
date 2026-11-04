import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/widgets/app_bottom_sheet.dart';
import '../../../../common/widgets/app_text_field.dart';
import '../../../../common/widgets/gradient_button.dart';
import '../../../../core/routes/app_navigator.dart';
import '../../../auth/presentations/widgets/password_strength_meter.dart';
import '../../bloc/settings_cubit.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      title: 'Đổi mật khẩu',
      subtitle: 'Các thiết bị khác sẽ cần đăng nhập lại',
      builder: (_) => const ChangePasswordSheet(),
    );
  }

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  Map<String, String> _errors = const {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _next.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final errors = <String, String>{
      if (_current.text.length < 6) 'current': 'Mật khẩu hiện tại không đúng',
      if (PasswordStrengthMeter.scoreOf(_next.text) < 2)
        'next': 'Mật khẩu mới chưa đủ mạnh',
      if (_next.text == _current.text && _next.text.isNotEmpty)
        'next': 'Mật khẩu mới phải khác mật khẩu cũ',
      if (_confirm.text != _next.text) 'confirm': 'Mật khẩu xác nhận không khớp',
    };
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    setState(() => _saving = true);
    await context.read<SettingsCubit>().changePassword(_current.text, _next.text);
    if (!mounted) return;
    AppNavigator.showMessage(context, 'Đã đổi mật khẩu thành công');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            label: 'Mật khẩu hiện tại',
            controller: _current,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            errorText: _errors['current'],
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Mật khẩu mới',
            controller: _next,
            obscureText: true,
            prefixIcon: Icons.lock_reset_rounded,
            errorText: _errors['next'],
          ),
          const SizedBox(height: 8),
          PasswordStrengthMeter(password: _next.text),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Nhập lại mật khẩu mới',
            controller: _confirm,
            obscureText: true,
            prefixIcon: Icons.check_circle_outline_rounded,
            errorText: _errors['confirm'],
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Cập nhật mật khẩu',
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
