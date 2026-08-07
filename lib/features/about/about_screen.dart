import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/data/story_repository.dart';
import 'package:qaari_sl_mobile/core/models/story.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStory = ref.watch(storyProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: asyncStory.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (error, _) => AsyncBody(
          isLoading: false,
          error: error,
          isEmpty: false,
          onRetry: () => ref.invalidate(storyProvider),
          child: const SizedBox.shrink(),
        ),
        data: (story) => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 210,
              backgroundColor: AppColors.forest,
              foregroundColor: AppColors.cream,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.forest,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    MediaQuery.paddingOf(context).top + 56,
                    24,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const QaariLogo(size: 56),
                      const SizedBox(height: 12),
                      Text(
                        'The Story So Far',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.cream,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (story.heroMission.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    story.heroMission,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 15,
                      height: 1.65,
                    ),
                  ),
                ),
              ),
            if (story.president.isNotEmpty ||
                story.ministers.isNotEmpty ||
                story.board.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: _SectionHeading(
                  eyebrow: 'PATRONS',
                  title: 'Patrons & Leadership',
                ),
              ),
              if (story.president.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (final person in story.president)
                          _LeaderCard(person: person, large: true),
                      ],
                    ),
                  ),
                ),
              if (story.ministers.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _LeaderCard(person: story.ministers[index]),
                      childCount: story.ministers.length,
                    ),
                  ),
                ),
              if (story.board.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      'BOARD MEMBERS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  sliver: SliverList.separated(
                    itemCount: story.board.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _BoardRow(person: story.board[index]),
                  ),
                ),
              ],
            ],
            if (story.team.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: _SectionHeading(
                  eyebrow: 'TEAM',
                  title: 'Behind the Voices',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                sliver: SliverList.separated(
                  itemCount: story.team.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _TeamRow(person: story.team[index]),
                ),
              ),
            ],
            if (story.closingNote.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      story.closingNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.cream.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.65,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStory = ref.watch(storyProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Credits')),
      body: asyncStory.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (error, _) => AsyncBody(
          isLoading: false,
          error: error,
          isEmpty: false,
          onRetry: () => ref.invalidate(storyProvider),
          child: const SizedBox.shrink(),
        ),
        data: (story) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            const Center(child: QaariLogo(size: 64)),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 20),
            if (story.closingNote.isNotEmpty)
              Text(
                story.closingNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  height: 1.65,
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.creamCard,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppColors.cardShadow,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acknowledgements',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Quran text uses an open Uthmani dataset.\n'
                    'Recitations are preserved for the Somali community at home and in the diaspora.',
                    style: TextStyle(
                      color: AppColors.muted,
                      height: 1.55,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Column(
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
          ),
        ],
      ),
    );
  }
}

class _LeaderCard extends StatelessWidget {
  const _LeaderCard({required this.person, this.large = false});

  final StoryPerson person;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 110.0 : 84.0;
    return Container(
      width: large ? double.infinity : null,
      margin: large ? const EdgeInsets.only(bottom: 12) : null,
      padding: EdgeInsets.all(large ? 20 : 14),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          NetworkAvatar(
            url: person.photoUrl,
            size: size,
            nameForFallback: person.name,
          ),
          const SizedBox(height: 12),
          Text(
            person.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: large ? 18 : 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            person.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardRow extends StatelessWidget {
  const _BoardRow({required this.person});

  final StoryPerson person;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          NetworkAvatar(
            url: person.photoUrl,
            size: 52,
            nameForFallback: person.name,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  person.title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.person});

  final StoryPerson person;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetworkAvatar(
            url: person.photoUrl,
            size: 48,
            nameForFallback: person.name,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  person.title,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((person.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    person.description!,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
