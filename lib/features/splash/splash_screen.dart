import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/home/home_shell.dart';
import 'package:qaari_sl_mobile/features/onboarding/onboarding_screen.dart';
import 'package:qaari_sl_mobile/features/onboarding/onboarding_store.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _leave();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    final done = OnboardingStore.isComplete();
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    final complete = await done;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => complete ? const HomeShell() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const QaariLogo(size: 130, light: true),
            const SizedBox(height: 28),
            Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: AppTheme.displayFont(
                fontSize: 34,
                color: AppColors.goldLight,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'SAFWAT AL-QURRA · XULKA QURAADA',
              style: AppTheme.sans(
                color: AppColors.cream.withValues(alpha: 0.45),
                fontSize: 10,
                weight: FontWeight.w700,
              ).copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final t = (_pulse.value + i * 0.22) % 1.0;
                    final opacity = t < 0.4
                        ? 0.2 + (t / 0.4) * 0.8
                        : 1.0 - ((t - 0.4) / 0.6) * 0.8;
                    final scale = 0.8 + opacity * 0.2;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity.clamp(0.2, 1.0),
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
