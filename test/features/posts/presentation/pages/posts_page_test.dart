import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/widgets/app_loader.dart';
import 'package:flutter_clean_starter/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:flutter_clean_starter/features/posts/presentation/pages/posts_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';
import '../../helpers/post_fixtures.dart';

class _MockPostsBloc extends MockBloc<PostsEvent, PostsState>
    implements PostsBloc;

void main() {
  late _MockPostsBloc bloc;

  setUp(() => bloc = _MockPostsBloc());

  Future<void> pumpPage(
    WidgetTester tester, {
    ValueChanged<int>? onPostTap,
    Locale locale = const Locale('en'),
  }) => tester.pumpApp(
    BlocProvider<PostsBloc>.value(
      value: bloc,
      child: PostsPage(onPostTap: onPostTap ?? (_) {}),
    ),
    locale: locale,
  );

  testWidgets('shows a loader while loading', (tester) async {
    when(() => bloc.state).thenReturn(const PostsLoading());
    await pumpPage(tester);
    expect(find.byType(AppLoader), findsOneWidget);
  });

  testWidgets('lists posts and reports taps', (tester) async {
    when(() => bloc.state)
        .thenReturn(const PostsLoaded([Fixtures.post, Fixtures.post2]));
    int? tapped;
    await pumpPage(tester, onPostTap: (id) => tapped = id);

    expect(find.text('title 1'), findsOneWidget);
    expect(find.text('title 2'), findsOneWidget);

    await tester.tap(find.text('title 2'));
    expect(tapped, 2);
  });

  testWidgets('shows the empty state', (tester) async {
    when(() => bloc.state).thenReturn(const PostsLoaded([]));
    await pumpPage(tester);
    expect(find.text('No posts yet.'), findsOneWidget);
  });

  testWidgets('shows the error and retries', (tester) async {
    when(() => bloc.state).thenReturn(const PostsFailure(NetworkFailure()));
    await pumpPage(tester);

    expect(find.textContaining("Can't reach the server"), findsOneWidget);
    await tester.tap(find.text('Retry'));
    verify(() => bloc.add(const PostsRequested())).called(1);
  });

  testWidgets('shows a snackbar when a refresh fails', (tester) async {
    whenListen(
      bloc,
      Stream.value(
        const PostsLoaded([Fixtures.post], refreshFailure: ServerFailure()),
      ),
      initialState: const PostsLoaded([Fixtures.post]),
    );
    await pumpPage(tester);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('is localized and lays out right-to-left in Arabic', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(const PostsLoaded([Fixtures.post]));
    await pumpPage(tester, locale: const Locale('ar'));

    expect(find.text('المنشورات'), findsOneWidget);
    final direction = Directionality.of(tester.element(find.text('title 1')));
    expect(direction, TextDirection.rtl);
  });
}
