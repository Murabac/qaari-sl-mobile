import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/auth/auth_controller.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/locale/locale_controller.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/about/about_screen.dart';
import 'package:qaari_sl_mobile/features/auth/login_screen.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return Column(
      children: [
        const ForestPageHeader(title: 'Settings'),
        Expanded(
          child: ColoredBox(
            color: AppColors.cream,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                const _SectionLabel('LANGUAGE'),
                _GroupedCard(
                  children: [
                    for (final option in _languages)
                      _SettingsTile(
                        leading: const Icon(
                          Icons.language_rounded,
                          color: AppColors.gold,
                          size: 18,
                        ),
                        title: option.label,
                        subtitle: option.native,
                        subtitleAmiri: option.code == 'ar',
                        trailing: locale.languageCode == option.code
                            ? Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: AppColors.forest,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.gold,
                                  size: 14,
                                ),
                              )
                            : null,
                        onTap: () => ref
                            .read(localeControllerProvider.notifier)
                            .setLocale(Locale(option.code)),
                        showDivider: option != _languages.last,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SectionLabel('ACCOUNT'),
                _GroupedCard(
                  children: [
                    if (auth.isAuthenticated && auth.user != null) ...[
                      _SettingsTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppColors.forest,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            auth.user!.name.isNotEmpty
                                ? auth.user!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        title: auth.user!.name,
                        subtitle: auth.user!.email,
                        showDivider: true,
                      ),
                      _SettingsTile(
                        leading: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.gold,
                          size: 18,
                        ),
                        title: 'Sign Out',
                        onTap: () =>
                            ref.read(authControllerProvider.notifier).logout(),
                      ),
                    ] else
                      _SettingsTile(
                        leading: const Icon(
                          Icons.login_rounded,
                          color: AppColors.gold,
                          size: 18,
                        ),
                        title: 'Sign In / Register',
                        subtitle: 'Save favorites across devices',
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.gold,
                          size: 18,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SectionLabel('ABOUT'),
                _GroupedCard(
                  children: [
                    _SettingsTile(
                      leading: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.gold,
                        size: 18,
                      ),
                      title: 'About ${AppConstants.appName}',
                      subtitle: 'The Story So Far',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.gold,
                        size: 18,
                      ),
                      showDivider: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      ),
                    ),
                    _SettingsTile(
                      leading: const Icon(
                        Icons.star_outline_rounded,
                        color: AppColors.gold,
                        size: 18,
                      ),
                      title: 'Rate the App',
                      subtitle: 'Share your feedback',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.gold,
                        size: 18,
                      ),
                      showDivider: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Ratings will be available after store release.',
                            ),
                          ),
                        );
                      },
                    ),
                    _SettingsTile(
                      leading: const Icon(
                        Icons.menu_book_outlined,
                        color: AppColors.gold,
                        size: 18,
                      ),
                      title: 'Credits',
                      subtitle: 'Acknowledgements & closing note',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.gold,
                        size: 18,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreditsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Center(child: QaariLogo(size: 36)),
                const SizedBox(height: 6),
                Text(
                  '${AppConstants.appName} v1.0.0 · For the Somali community',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _GroupedCard extends StatelessWidget {
  const _GroupedCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = false,
    this.subtitleAmiri = false,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool subtitleAmiri;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: subtitleAmiri
                              ? AppTheme.amiri(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                  height: 1.3,
                                )
                              : const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.cream, indent: 16),
      ],
    );
  }
}

class _Lang {
  const _Lang(this.code, this.label, this.native);
  final String code;
  final String label;
  final String native;
}

const _languages = [
  _Lang('en', 'English', 'English'),
  _Lang('so', 'Somali', 'Soomaali'),
  _Lang('ar', 'Arabic', 'العربية'),
];
