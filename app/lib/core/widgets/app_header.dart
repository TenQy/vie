import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 70 : 60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      title: _buildTitle(),
      actions: actions,
    );
  }

  Widget _buildTitle() {
    if (subtitle == null) {
      return Text(
        title,
        style: AppTypography.displayMedium.copyWith(fontSize: 24),
      );
    }

    return Column(
      crossAxisAlignment:
          centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle!,
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}
