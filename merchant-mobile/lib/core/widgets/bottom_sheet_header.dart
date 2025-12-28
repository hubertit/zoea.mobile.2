import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/dimensions.dart';

/// Reusable bottom sheet header with drag handle
class BottomSheetHeader extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const BottomSheetHeader({
    super.key,
    this.title,
    this.trailing,
    this.showCloseButton = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Dimensions.vSpace12,
        // Drag handle
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.dividerColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (title != null || showCloseButton || trailing != null) ...[
          Dimensions.vSpace16,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.screenPadding),
            child: Row(
              children: [
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (trailing != null) trailing!,
                if (showCloseButton)
                  IconButton(
                    onPressed: onClose ?? () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
        Dimensions.vSpace16,
      ],
    );
  }
}

/// Reusable bottom sheet container
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final bool showCloseButton;
  final EdgeInsets? padding;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.showCloseButton = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHeader(
            title: title,
            trailing: trailing,
            showCloseButton: showCloseButton,
          ),
          Padding(
            padding: padding ?? Dimensions.bottomSheetAll.copyWith(top: 0),
            child: child,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

