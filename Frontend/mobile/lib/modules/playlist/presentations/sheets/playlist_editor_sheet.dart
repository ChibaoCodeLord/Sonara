import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_bottom_sheet.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../../../common/widgets/app_text_field.dart';
import '../../../../common/widgets/gradient_button.dart';
import '../../../../core/catalog/catalog_images.dart';
import '../../../library/bloc/library_cubit.dart';
import '../../../library/models/library_playlist_model.dart';

/// SCR-09: create a new personal playlist or edit an existing one.
class PlaylistEditorSheet extends StatefulWidget {
  final LibraryPlaylistModel? existing;

  const PlaylistEditorSheet({super.key, this.existing});

  static Future<LibraryPlaylistModel?> show(
    BuildContext context, {
    LibraryPlaylistModel? existing,
  }) {
    return showAppBottomSheet<LibraryPlaylistModel>(
      context: context,
      title: existing == null ? 'Tạo danh sách phát' : 'Chỉnh sửa playlist',
      subtitle: 'Tự tổ chức bộ sưu tập nhạc của riêng bạn',
      builder: (_) => PlaylistEditorSheet(existing: existing),
    );
  }

  @override
  State<PlaylistEditorSheet> createState() => _PlaylistEditorSheetState();
}

class _PlaylistEditorSheetState extends State<PlaylistEditorSheet> {
  static const _covers = [
    CatalogImages.sonaraAiMix,
    CatalogImages.mixAcoustic,
    CatalogImages.mixLofiNight,
    CatalogImages.mixIndieViet,
    CatalogImages.playlistLofiChill,
    CatalogImages.playlistVpopIndie,
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _cover;
  late bool _isPublic;
  late bool _isCollaborative;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController =
        TextEditingController(text: existing?.description ?? '');
    _cover = existing?.coverUrl ?? _covers.first;
    _isPublic = existing?.isPublic ?? true;
    _isCollaborative = existing?.isCollaborative ?? false;
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final cubit = context.read<LibraryCubit>();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final LibraryPlaylistModel result;
    if (_isEditing) {
      result = widget.existing!.copyWith(
        title: title,
        description: description,
        coverUrl: _cover,
        isPublic: _isPublic,
        isCollaborative: _isCollaborative,
        badgeLabel: _isCollaborative ? 'Cộng tác' : 'Cá nhân',
      );
      cubit.updatePlaylist(result);
    } else {
      result = cubit.createPlaylist(
        title: title,
        description: description,
        coverUrl: _cover,
        isPublic: _isPublic,
        isCollaborative: _isCollaborative,
      );
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                AppNetworkImage(
                  imageUrl: _cover,
                  width: 132,
                  height: 132,
                  borderRadius: 20,
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceCrisp,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Ảnh bìa',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _covers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final cover = _covers[index];
                final selected = cover == _cover;
                return GestureDetector(
                  onTap: () => setState(() => _cover = cover),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: AppNetworkImage(
                      imageUrl: cover,
                      width: 48,
                      height: 48,
                      borderRadius: 9,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Tên danh sách phát',
            hint: 'VD: Giai điệu chiều thứ Bảy',
            controller: _titleController,
            maxLength: 60,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Mô tả (không bắt buộc)',
            hint: 'Thêm vài dòng về playlist này',
            controller: _descriptionController,
            maxLines: 3,
            maxLength: 200,
          ),
          const SizedBox(height: 14),
          _buildSwitch(
            icon: Icons.public_rounded,
            title: 'Công khai (Public)',
            subtitle: 'Mọi người có thể tìm thấy và nghe playlist này',
            value: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v),
          ),
          _buildSwitch(
            icon: Icons.group_add_rounded,
            title: 'Cộng tác (Collaborative)',
            subtitle: 'Cho phép bạn bè cùng thêm bài hát',
            value: _isCollaborative,
            onChanged: (v) => setState(() => _isCollaborative = v),
          ),
          const SizedBox(height: 18),
          GradientButton(
            label: _isEditing ? 'Lưu thay đổi' : 'Tạo playlist',
            icon: _isEditing ? Icons.check_rounded : Icons.add_rounded,
            onPressed: _titleController.text.trim().isEmpty ? null : _save,
          ),
          if (_isEditing) ...[
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  context
                      .read<LibraryCubit>()
                      .deletePlaylist(widget.existing!.id);
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Xóa playlist',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textCharcoal, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(subtitle, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
