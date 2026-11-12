import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/app/app.dart';
import 'package:qaari_sl_mobile/core/auth/token_store.dart';
import 'package:qaari_sl_mobile/core/data/auth_repository.dart';
import 'package:qaari_sl_mobile/core/data/catalog_repository.dart';
import 'package:qaari_sl_mobile/core/follow_along/ayah_index.dart';
import 'package:qaari_sl_mobile/core/locale/locale_controller.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/core/models/surah.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/core/network/api_client.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qaari_sl_mobile/features/player/audio_handler.dart';
import 'package:qaari_sl_mobile/features/player/open_player.dart';
import 'package:qaari_sl_mobile/core/theme/theme_mode_controller.dart';
import 'package:qaari_sl_mobile/features/onboarding/onboarding_store.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Surah and Reciter parse API JSON', () {
    final surah = Surah.fromJson({
      'id': 1,
      'number': 1,
      'name_arabic': 'الفاتحة',
      'name_somali': 'Al-Faatiha',
      'name_english': 'Al-Fatihah',
      'verse_count': 7,
    });
    expect(surah.titleLine, '1. Al-Fatihah');
    expect(surah.localizedName('ar'), 'الفاتحة');

    final reciter = Reciter.fromJson({
      'id': 3,
      'name_somali': 'Sheekh',
      'name_arabic': 'شيخ',
      'name_english': 'Sheikh',
      'bio_somali': '',
      'bio_arabic': '',
      'bio_english': 'A beloved reciter.',
      'photo_url': 'https://example.com/p.jpg',
      'region': 'Hargeisa',
      'approved_recitations_count': 2,
      'recitations': [
        {
          'id': 10,
          'reciter_id': 3,
          'surah_id': 1,
          'audio_url': 'https://example.com/a.mp3',
          'duration': 125,
          'file_size': 1000,
          'surah': {
            'id': 1,
            'number': 1,
            'name_arabic': 'الفاتحة',
            'name_somali': 'Al-Faatiha',
            'name_english': 'Al-Fatihah',
            'verse_count': 7,
          },
        },
      ],
    });

    expect(reciter.localizedName('en'), 'Sheikh');
    expect(reciter.recitations, hasLength(1));
    expect(reciter.recitations.first.durationLabel, '2:05');
  });

  test('ayahIndexFromStarts uses timings then equal-time fallback', () {
    expect(
      ayahIndexFromStarts(
        positionSeconds: 0.5,
        ayahStarts: const [2.0, 8.0, 14.0],
        verseCount: 3,
        durationSeconds: 20,
      ),
      -1,
    );
    expect(
      ayahIndexFromStarts(
        positionSeconds: 8.5,
        ayahStarts: const [2.0, 8.0, 14.0],
        verseCount: 3,
        durationSeconds: 20,
      ),
      1,
    );
    expect(
      ayahIndexFromStarts(
        positionSeconds: 10,
        ayahStarts: const [],
        verseCount: 4,
        durationSeconds: 40,
      ),
      1,
    );
  });

  test('Dio attaches Bearer token from store', () async {
    final store = _MemoryTokenStore('secret-token');
    final dio = createApiClient(
      baseUrl: 'http://example.com',
      tokenStore: store,
    );

    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: {}),
          );
        },
      ),
    );

    await dio.get<void>('/auth/me');
    expect(captured.headers['Authorization'], 'Bearer secret-token');
  });

  test('LocaleController applyCode updates locale', () {
    final controller = LocaleController(autoLoad: false);
    controller.applyCode('ar');
    expect(controller.state, const Locale('ar'));
    controller.applyCode('en');
    expect(controller.state, const Locale('en'));
  });

  test('ThemeModeController defaults to dark', () {
    final controller = ThemeModeController(autoLoad: false);
    expect(controller.state, ThemeMode.dark);
    controller.applyCode('light');
    expect(controller.state, ThemeMode.light);
    controller.applyCode('system');
    expect(controller.state, ThemeMode.system);
    controller.applyCode('nope');
    expect(controller.state, ThemeMode.system);
  });

  testWidgets('Qaari SL app boots to home shell', (tester) async {
    SharedPreferences.setMockInitialValues({OnboardingStore.prefsKey: true});
    final handler = QaariAudioHandler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioHandlerProvider.overrideWithValue(handler),
          catalogRepositoryProvider.overrideWithValue(_FakeCatalog()),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore(null)),
          authRepositoryProvider.overrideWithValue(_GuestAuthRepository()),
          localeControllerProvider.overrideWith(
            (ref) => LocaleController(autoLoad: false),
          ),
        ],
        child: const QaariSlApp(),
      ),
    );

    expect(find.text('Xulka Quraada'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Qaariyada la soo bandhigay'), findsOneWidget);
    expect(find.text('Demo'), findsWidgets);
    expect(find.text('Dhageyso hadda'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('first launch tours the app then asks for notifications', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final handler = QaariAudioHandler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioHandlerProvider.overrideWithValue(handler),
          catalogRepositoryProvider.overrideWithValue(_FakeCatalog()),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore(null)),
          authRepositoryProvider.overrideWithValue(_GuestAuthRepository()),
          localeControllerProvider.overrideWith(
            (ref) => LocaleController(autoLoad: false),
          ),
        ],
        child: const QaariSlApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Kusoo dhawoow Xulka Quraada'), findsOneWidget);
    expect(find.text('Ka bood'), findsOneWidget);

    await tester.tap(find.text('Ka bood'));
    await tester.pumpAndSettle();

    expect(find.text('Ogeysiisyada'), findsOneWidget);
    expect(find.text('Oggolow'), findsOneWidget);
    expect(find.text('Hadda ma aha'), findsOneWidget);

    await tester.tap(find.text('Hadda ma aha'));
    await tester.pumpAndSettle();

    expect(find.text('Dhageyso hadda'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(OnboardingStore.prefsKey), isTrue);
  });

  test('finished playback restarts from the beginning', () {
    expect(playbackNeedsRestart(ProcessingState.completed), isTrue);
    expect(playbackNeedsRestart(ProcessingState.ready), isFalse);
    expect(playbackNeedsRestart(ProcessingState.idle), isFalse);
  });

  test('Listen now uses loaded tracks before fetching the profile', () async {
    final listed = Reciter.fromJson({
      'id': 1,
      'name_somali': 'Demo',
      'name_arabic': '',
      'name_english': 'Demo',
      'bio_somali': '',
      'bio_arabic': '',
      'bio_english': '',
      'photo_url': null,
      'region': 'Harar',
      'approved_recitations_count': 1,
      'recitations': [
        {
          'id': 9,
          'reciter_id': 1,
          'surah_id': 1,
          'audio_url': 'https://example.com/ready.mp3',
          'duration': 30,
          'file_size': 10,
        },
      ],
    });
    final catalog = _QueueCatalog();
    final queue = await resolveListenQueue(listed, catalog);
    expect(queue, hasLength(1));
    expect(queue.first.id, 9);
    expect(catalog.fetched, isFalse);

    final bare = Reciter.fromJson({
      'id': 2,
      'name_somali': 'Bare',
      'name_arabic': '',
      'name_english': 'Bare',
      'bio_somali': '',
      'bio_arabic': '',
      'bio_english': '',
      'photo_url': null,
      'region': null,
      'approved_recitations_count': 1,
    });
    final loaded = await resolveListenQueue(bare, catalog);
    expect(catalog.fetched, isTrue);
    expect(loaded.single.audioUrl, 'https://example.com/fetched.mp3');
  });
}

class _MemoryTokenStore extends TokenStore {
  _MemoryTokenStore(this._token);

  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

class _GuestAuthRepository extends AuthRepository {
  _GuestAuthRepository()
    : super(dio: Dio(), tokenStore: _MemoryTokenStore(null));

  @override
  Future<String?> readToken() async => null;

  @override
  Future<void> clearLocalSession() async {}

  @override
  Future<void> logout() async {}
}

class _QueueCatalog extends _FakeCatalog {
  var fetched = false;

  @override
  Future<Reciter> fetchReciter(int id) async {
    fetched = true;
    return Reciter.fromJson({
      'id': id,
      'name_somali': 'Bare',
      'name_arabic': '',
      'name_english': 'Bare',
      'bio_somali': '',
      'bio_arabic': '',
      'bio_english': '',
      'photo_url': null,
      'region': null,
      'approved_recitations_count': 1,
      'recitations': [
        {
          'id': 4,
          'reciter_id': id,
          'surah_id': 1,
          'audio_url': 'https://example.com/fetched.mp3',
          'duration': 12,
          'file_size': 10,
        },
      ],
    });
  }
}

class _FakeCatalog extends CatalogRepository {
  _FakeCatalog() : super(Dio());

  @override
  Future<List<Reciter>> fetchReciters({String? query}) async {
    return [
      Reciter.fromJson({
        'id': 1,
        'name_somali': 'Demo',
        'name_arabic': 'عرض',
        'name_english': 'Demo Reciter',
        'bio_somali': '',
        'bio_arabic': '',
        'bio_english': 'Bio',
        'photo_url': null,
        'region': 'Hargeisa',
        'approved_recitations_count': 1,
      }),
    ];
  }

  @override
  Future<Reciter> fetchReciter(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Recitation> fetchRecitation(int id) {
    throw UnimplementedError();
  }
}
