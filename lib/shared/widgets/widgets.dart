import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_metrics.dart';
import 'package:qaari_sl_mobile/shared/widgets/qaari_logo.dart';

export 'design_primitives.dart';
export 'qaari_logo.dart';

class AsyncBody extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.isLoading,
    required this.error,
    required this.isEmpty,
    required this.onRetry,
    required this.child,
    this.emptyMessage = 'Nothing here yet',
    this.emptyWidget,
  });

  final bool isLoading;
  final Object? error;
  final bool isEmpty;
  final VoidCallback onRetry;
  final Widget child;
  final String emptyMessage;
  final Widget? emptyWidget;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const QaariLoadingSkeleton();
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load content',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.cream,
                ),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      return emptyWidget ??
          Center(
            child: Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.muted,
                  ),
              textAlign: TextAlign.center,
            ),
          );
    }

    return child;
  }
}

class QaariLoadingSkeleton extends StatelessWidget {
  const QaariLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        height: 84,
        decoration: BoxDecoration(
          color: AppColors.creamSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
      ),
    );
  }
}

class NetworkAvatar extends StatelessWidget {
  const NetworkAvatar({
    super.key,
    required this.url,
    this.size = 56,
    this.borderRadius,
    this.nameForFallback,
  });

  final String? url;
  final double size;
  final BorderRadius? borderRadius;
  final String? nameForFallback;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size / 2);
    final fallback = nameForFallback != null && nameForFallback!.isNotEmpty
        ? ReciterInitialsAvatar(name: nameForFallback!, size: size)
        : Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.12),
              borderRadius: radius,
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.forest,
              size: size * 0.45,
            ),
          );

    if (url == null || url!.isEmpty) {
      return fallback;
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
      ),
    );
  }
}

/// Premium cream header (legacy name kept for call sites).
class ForestPageHeader extends StatelessWidget {
  const ForestPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: AppColors.deep,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, top + 16, 20, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Color(0xFFE5B54F),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
