import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/features/home/home_shell.dart';
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
    Future<void>.delayed(const Duration(milliseconds: 1600), _goHome);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeShell()),
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
            const QaariLogo(size: 130),
            const SizedBox(height: 28),
            Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'SOMALI COMMUNITY QURAN RECITERS',
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.4),
                fontSize: 11,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w600,
              ),
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
