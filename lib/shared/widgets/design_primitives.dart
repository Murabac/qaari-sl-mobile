import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/locale/locale_controller.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_palette.dart';
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
          if (bottom != null) ...[const SizedBox(height: 14), bottom!],
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
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeControllerProvider).languageCode;
    final subtitle = switch (code) {
      'ar' => 'أصوات وتلاوات القراء الصوماليين',
      'so' => 'Akhriska Quraanka Quraada Soomaaliyeed',
      _ => 'Somali Quran Reciters Anthology',
    };

    return ColoredBox(
      color: AppColors.deep,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.paddingOf(context).top + 10,
          16,
          14,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const QaariLogo(size: 44, light: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              AppConstants.appName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.sans(
                                fontSize: 18,
                                color: Colors.white,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x33D4AF37),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'TILAWA',
                              style: AppTheme.sans(
                                fontSize: 9,
                                color: const Color(0xFFF3D082),
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.sans(
                          fontSize: 11,
                          color: const Color(0xFFA3B8B0),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showDailyAyah(context),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF103D30),
                    foregroundColor: AppColors.goldLight,
                    side: const BorderSide(color: Color(0x1FFFFFFF)),
                  ),
                  icon: const Icon(Icons.notifications_none_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: AppTheme.sans(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: searchHint,
                hintStyle: AppTheme.sans(
                  fontSize: 14,
                  color: const Color(0xFF7A988D),
                ),
                filled: true,
                fillColor: const Color(0xFF0F352A),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF7A988D),
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyAyah(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFFAF8F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTheme.amiri(fontSize: 26, color: AppColors.ink),
              ),
              const SizedBox(height: 12),
              Text(
                'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTheme.amiri(fontSize: 22, color: AppColors.forest),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: AppTheme.sans(
                    color: AppColors.forest,
                    weight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
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
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 18,
          color: AppColors.muted,
        ),
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
              icon: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.muted,
              ),
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
                color: selectedIndex == i
                    ? AppColors.forest
                    : Colors.transparent,
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

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null && eyebrow!.isNotEmpty)
                  Text(
                    eyebrow!.toUpperCase(),
                    style: AppTheme.sans(
                      fontSize: 11,
                      color: palette.accent,
                      weight: FontWeight.w600,
                      letterSpacing: 1.6,
                    ),
                  ),
                Text(
                  title,
                  style: AppTheme.displayFont(
                    fontSize: 34,
                    color: palette.text,
                    weight: FontWeight.w600,
                    letterSpacing: -0.6,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTheme.sans(fontSize: 13, color: palette.muted),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTheme.displayFont(
              fontSize: 22,
              color: palette.text,
              weight: FontWeight.w600,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: AppTheme.sans(
                fontSize: 13,
                color: palette.accent,
                weight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

enum PillButtonKind { filled, outline }

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = PillButtonKind.filled,
    this.icon,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillButtonKind kind;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final filled = kind == PillButtonKind.filled;
    final foreground = filled ? palette.onPrimary : palette.text;
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: filled ? palette.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(height / 2),
          border: filled ? null : Border.all(color: palette.line),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(height / 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: foreground),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(
                        fontSize: 15,
                        color: foreground,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 42,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: palette.navGlass,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, size: size * 0.46, color: palette.text),
            ),
          ),
        ),
      ),
    );
  }
}

class SegmentedPill extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.chip,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == index ? palette.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(
                        fontSize: 13,
                        color: i == index ? palette.onPrimary : palette.muted,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.line),
      ),
      child: Column(children: children),
    );
  }
}

class GroupRow extends StatelessWidget {
  const GroupRow({
    super.key,
    required this.label,
    this.onTap,
    this.trailing,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = danger ? palette.danger : palette.text;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTheme.sans(
                  fontSize: 15,
                  color: color,
                  weight: FontWeight.w600,
                ),
              ),
            ),
            ?trailing,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right_rounded, color: palette.muted),
          ],
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
      shape: const CircleBorder(side: BorderSide(color: AppColors.forestSoft)),
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
