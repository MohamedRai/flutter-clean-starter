import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/app/app.dart';
import 'package:flutter_clean_starter/app/di/injection.dart';
import 'package:flutter_clean_starter/app/flavors/flavor_config.dart';
import 'package:flutter_clean_starter/core/storage/secure_storage.dart';
import 'package:flutter_clean_starter/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:flutter_clean_starter/features/posts/data/models/post_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// example:begin
/// Serves fixed posts so the test never touches the network.
class _FakeRemote implements PostRemoteDataSource {
  static const posts = [
    PostModel(id: 1, userId: 1, title: 'first post', body: 'hello'),
    PostModel(id: 2, userId: 2, title: 'second post', body: 'world'),
  ];

  @override
  Future<List<PostModel>> getPosts() async => posts;

  @override
  Future<PostModel> getPost(int id) async =>
      posts.firstWhere((p) => p.id == id);
}
// example:end

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
    await configureDependencies(
      const FlavorConfig(
        flavor: Flavor.dev,
        apiBaseUrl: 'https://example.invalid',
        enableHttpLogs: false,
      ),
    );
    await getIt<SecureStorage>().deleteAll(); // start signed out
    // Swap network-bound data sources for fakes here.
    getIt.allowReassignment = true;
    // example:begin
    getIt.registerLazySingleton<PostRemoteDataSource>(_FakeRemote.new);
    // example:end
  });

  // example:begin
  testWidgets('browses posts: list → detail → back', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('first post'), findsOneWidget);
    expect(find.text('second post'), findsOneWidget);

    await tester.tap(find.text('second post'));
    await tester.pumpAndSettle();
    expect(find.text('World'), findsOneWidget); // body, capitalized
    expect(find.text('By user #2'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('first post'), findsOneWidget);
  });
  // example:end

  testWidgets('auth guard: account requires sign-in', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    // Redirected to sign-in…
    expect(find.text('Sign in (demo)'), findsOneWidget);
    await tester.tap(find.text('Sign in (demo)'));
    await tester.pumpAndSettle();

    // …and back to the page originally requested.
    expect(find.text('You are signed in (demo session).'), findsOneWidget);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in (demo)'), findsOneWidget);
  });

  testWidgets('switches to Arabic (right-to-left)', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(find.text('الإعدادات'), findsWidgets);
    final direction = Directionality.of(tester.element(find.text('اللغة')));
    expect(direction, TextDirection.rtl);
  });
}
