import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/home/home_shell.dart';
import 'package:qaari_sl_mobile/features/onboarding/onboarding_store.dart';
import 'package:qaari_sl_mobile/features/onboarding/playback_notification_permission.dart';
import 'package:qaari_sl_mobile/l10n/app_localizations.dart';
import 'package:qaari_sl_mobile/shared/widgets/qaari_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.requestNotifications});

  /// Used by tests. Defaults to the Android 13+ notification request.
  final Future<void> Function()? requestNotifications;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int get _permissionPage => AppFeatures.moments ? 4 : 3;

  final _page = PageController();
  int _index = 0;
  bool _leaving = false;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index) async {
    await _page.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _primary() async {
    if (_index < _permissionPage) {
      await _goTo(_index + 1);
      return;
    }
    await _finish(request: true);
  }

  Future<void> _finish({required bool request}) async {
    if (_leaving) return;
    setState(() => _leaving = true);
    if (request) {
      try {
        await (widget.requestNotifications ?? requestPlaybackNotifications)();
      } catch (_) {
        // A denied or unavailable prompt still lets the listener in.
      }
    }
    await OnboardingStore.markComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final permissionPage = _index == _permissionPage;

    return Scaffold(
      backgroundColor: AppColors.deep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _page,
                  onPageChanged: (index) => setState(() => _index = index),
                  children: [
                    _TourPage(
                      title: l10n.onboardingWelcomeTitle,
                      body: l10n.onboardingWelcomeBody,
                      mark: const QaariLogo(size: 112, light: true),
                    ),
                    _TourPage(
                      title: l10n.onboardingRecitersTitle,
                      body: l10n.onboardingRecitersBody,
                      icon: Icons.person_outline,
                    ),
                    _TourPage(
                      title: l10n.onboardingFollowTitle,
                      body: l10n.onboardingFollowBody,
                      icon: Icons.menu_book_outlined,
                    ),
                    if (AppFeatures.moments)
                      _TourPage(
                        title: l10n.onboardingMomentsTitle,
                        body: l10n.onboardingMomentsBody,
                        icon: Icons.play_circle_outline,
                      ),
                    _TourPage(
                      title: l10n.onboardingNotificationsTitle,
                      body: l10n.onboardingNotificationsBody,
                      icon: Icons.notifications_none_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Dots(count: AppFeatures.moments ? 5 : 4, index: _index),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _leaving ? null : _primary,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    disabledBackgroundColor: AppColors.gold.withValues(
                      alpha: 0.5,
                    ),
                    foregroundColor: AppColors.deep,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: AppTheme.sans(
                      fontSize: 16,
                      weight: FontWeight.w700,
                      color: AppColors.deep,
                    ),
                  ),
                  child: Text(
                    permissionPage ? l10n.onboardingAllow : l10n.onboardingNext,
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: _leaving
                      ? null
                      : () {
                          if (permissionPage) {
                            _finish(request: false);
                          } else {
                            _goTo(_permissionPage);
                          }
                        },
                  child: Text(
                    permissionPage
                        ? l10n.onboardingNotNow
                        : l10n.onboardingSkip,
                    style: AppTheme.sans(
                      color: AppColors.cream.withValues(alpha: 0.72),
                      fontSize: 15,
                      weight: FontWeight.w600,
                    ),
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

class _TourPage extends StatelessWidget {
  const _TourPage({
    required this.title,
    required this.body,
    this.icon,
    this.mark,
  });

  final String title;
  final String body;
  final IconData? icon;
  final Widget? mark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (mark != null)
                    mark!
                  else
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withValues(alpha: 0.14),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Icon(icon, color: AppColors.goldLight, size: 40),
                    ),
                  const SizedBox(height: 36),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTheme.displayFont(
                      fontSize: 34,
                      color: AppColors.goldLight,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: AppTheme.sans(
                      fontSize: 16,
                      color: AppColors.cream.withValues(alpha: 0.78),
                      weight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? AppColors.gold
                : AppColors.cream.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
