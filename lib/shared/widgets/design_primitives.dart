import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/locale/locale_controller.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/shared/widgets/qaari_logo.dart';

/// Premium cream page header used across Home, Settings, Favorites, Playlists.
class CreamPageHeader extends StatelessWidget {
  const CreamPageHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      decoration: AppColors.creamHeaderDecoration,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trailing != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _titleBlock()),
                trailing!,
              ],
            )
          else
            _titleBlock(),
          if (bottom != null) ...[
            const SizedBox(height: 14),
            bottom!,
          ],
        ],
      ),
    );
  }

  Widget _titleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null && eyebrow!.isNotEmpty)
          Text(
            eyebrow!.toUpperCase(),
            style: AppTheme.sans(
              fontSize: 11,
              color: AppColors.gold,
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.2),
          ),
        Text(
          title,
          style: AppTheme.displayFont(fontSize: 26, weight: FontWeight.w600),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTheme.sans(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

class HomeBrandHeader extends ConsumerWidget {
  const HomeBrandHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchHint,
    required this.greetingSmall,
    required this.greetingTitle,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;
  final String greetingSmall;
  final String greetingTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    return Container(
      decoration: AppColors.creamHeaderDecoration,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 12,
        20,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const QaariLogo(size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: AppTheme.displayFont(
                        fontSize: 18,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Safwat al-Qurra',
                      style: AppTheme.sans(
                        fontSize: 10,
                        color: AppColors.gold,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              LocaleSwitcherCompact(selected: locale.languageCode),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            greetingSmall,
            style: AppTheme.sans(
              fontSize: 12,
              color: AppColors.muted,
              weight: FontWeight.w600,
            ),
          ),
          Text(
            greetingTitle,
            style: AppTheme.displayFont(fontSize: 24, weight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          QaariSearchField(
            controller: searchController,
            hint: searchHint,
            onChanged: onSearchChanged,
          ),
        ],
      ),
    );
  }
}

class LocaleSwitcherCompact extends ConsumerWidget {
  const LocaleSwitcherCompact({super.key, required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in const ['en', 'so', 'ar'])
            _LangChip(
              code: code,
              active: selected == code,
              onTap: () => ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(Locale(code)),
            ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.code,
    required this.active,
    required this.onTap,
  });

  final String code;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.forest : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            code.toUpperCase(),
            style: AppTheme.sans(
              fontSize: 11,
              weight: active ? FontWeight.w700 : FontWeight.w600,
              color: active ? AppColors.goldLight : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class QaariSearchField extends StatelessWidget {
  const QaariSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTheme.sans(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.sans(fontSize: 13, color: AppColors.muted),
        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.muted),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.muted),
            );
          },
        ),
      ),
    );
  }
}

class QaariSegmentedBar extends StatelessWidget {
  const QaariSegmentedBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Material(
                color: selectedIndex == i ? AppColors.forest : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  onTap: () => onSelected(i),
                  borderRadius: BorderRadius.circular(9),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(
                        fontSize: 12,
                        weight: FontWeight.w600,
                        color: selectedIndex == i
                            ? AppColors.goldLight
                            : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FrostedSurface extends StatelessWidget {
  const FrostedSurface({
    super.key,
    required this.child,
    this.dark = false,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(0)),
  });

  final Widget child;
  final bool dark;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dark
                ? AppColors.deep.withValues(alpha: 0.92)
                : AppColors.creamCard.withValues(alpha: 0.94),
            border: Border(
              top: BorderSide(
                color: dark
                    ? AppColors.forestSoft.withValues(alpha: 0.55)
                    : AppColors.border,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class QaariForestIconButton extends StatelessWidget {
  const QaariForestIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.goldIcon = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool goldIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.forest.withValues(alpha: 0.82),
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.forestSoft),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: goldIcon ? AppColors.goldLight : AppColors.mutedOnDark,
          ),
        ),
      ),
    );
  }
}
