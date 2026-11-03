import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_bottom_sheet.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../common/widgets/gradient_button.dart';
import '../../../common/widgets/sub_page_header.dart';
import '../../../core/catalog/catalog_images.dart';
import '../../../core/routes/app_navigator.dart';
import '../bloc/profile_cubit.dart';

/// Edit display name, bio and avatar.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _avatars = [
    CatalogImages.userAvatar,
    CatalogImages.artistVu,
    CatalogImages.artistMiuLe,
    CatalogImages.artistHoangDung,
    CatalogImages.mixAcoustic,
    CatalogImages.sonaraAiMix,
  ];

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _bio;
  late String _avatar;
  String? _nameError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileCubit>().state.profile;
    _name = TextEditingController(text: profile.name);
    _email = TextEditingController(text: profile.email);
    _bio = TextEditingController(text: profile.bio);
    _avatar = profile.avatarUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _pickAvatar() {
    showAppBottomSheet<void>(
      context: context,
      title: 'Chọn ảnh đại diện',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final avatar in _avatars)
              GestureDetector(
                onTap: () {
                  setState(() => _avatar = avatar);
                  Navigator.of(sheetContext).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: avatar == _avatar ? AppColors.aiGradient : null,
                  ),
                  child: AppNetworkImage(
                    imageUrl: avatar,
                    width: 72,
                    height: 72,
                    borderRadius: 999,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    setState(() {
      _nameError = name.length < 2 ? 'Tên quá ngắn' : null;
      _emailError = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
          ? null
          : 'Email không hợp lệ';
    });
    if (_nameError != null || _emailError != null) return;
    context.read<ProfileCubit>().updateProfile(
          name: name,
          email: email,
          bio: _bio.text.trim(),
          avatarUrl: _avatar,
        );
    AppNavigator.showMessage(context, 'Đã cập nhật hồ sơ');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const SubPageHeader(title: 'Chỉnh sửa hồ sơ'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.aiGradient,
                          ),
                          child: AppNetworkImage(
                            imageUrl: _avatar,
                            width: 112,
                            height: 112,
                            borderRadius: 999,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCrisp,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: const Icon(
                              Icons.photo_camera_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _pickAvatar,
                    child: Text(
                      'Đổi ảnh đại diện',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Tên hiển thị',
                  controller: _name,
                  prefixIcon: Icons.person_outline_rounded,
                  maxLength: 40,
                  errorText: _nameError,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  controller: _email,
                  prefixIcon: Icons.mail_outline_rounded,
                  suffix: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.verified_rounded,
                      color: AppColors.emeraldActive,
                      size: 20,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Giới thiệu',
                  controller: _bio,
                  maxLines: 3,
                  maxLength: 150,
                  hint: 'Đôi dòng về gu âm nhạc của bạn',
                ),
                const SizedBox(height: 28),
                GradientButton(
                  label: 'Lưu thay đổi',
                  icon: Icons.check_rounded,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
