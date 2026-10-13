import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/features/posts/domain/usecases/get_posts.dart';
import 'package:flutter_clean_starter/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/post_fixtures.dart';

class _MockGetPosts extends Mock implements GetPosts;

void main() {
  late _MockGetPosts getPosts;

  setUpAll(() => registerFallbackValue(const GetPostsParams()));

  setUp(() => getPosts = _MockGetPosts());

  test('starts in PostsInitial', () {
    expect(PostsBloc(getPosts).state, const PostsInitial());
  });

  group('PostsRequested', () {
    blocTest<PostsBloc, PostsState>(
      'emits loading then loaded',
      setUp: () =>
          when(() => getPosts(const GetPostsParams()))
              .thenAnswer((_) async => const Result.success([Fixtures.post])),
      build: () => PostsBloc(getPosts),
      act: (bloc) => bloc.add(const PostsRequested()),
      expect: () => const [
        PostsLoading(),
        PostsLoaded([Fixtures.post]),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'emits loading then failure',
      setUp: () =>
          when(() => getPosts(const GetPostsParams()))
              .thenAnswer((_) async => const Result.failure(NetworkFailure())),
      build: () => PostsBloc(getPosts),
      act: (bloc) => bloc.add(const PostsRequested()),
      expect: () => const [PostsLoading(), PostsFailure(NetworkFailure())],
    );
  });

  group('PostsRefreshed', () {
    blocTest<PostsBloc, PostsState>(
      'replaces the posts without a loading state',
      setUp: () =>
          when(() => getPosts(const GetPostsParams(forceRefresh: true)))
              .thenAnswer((_) async => const Result.success([Fixtures.post2])),
      build: () => PostsBloc(getPosts),
      seed: () => const PostsLoaded([Fixtures.post]),
      act: (bloc) => bloc.add(const PostsRefreshed()),
      expect: () => const [
        PostsLoaded([Fixtures.post2]),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'keeps the posts and reports the failure',
      setUp: () =>
          when(() => getPosts(const GetPostsParams(forceRefresh: true)))
              .thenAnswer((_) async => const Result.failure(NetworkFailure())),
      build: () => PostsBloc(getPosts),
      seed: () => const PostsLoaded([Fixtures.post]),
      act: (bloc) => bloc.add(const PostsRefreshed()),
      expect: () => const [
        PostsLoaded([Fixtures.post], refreshFailure: NetworkFailure()),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'emits failure when there was nothing to keep',
      setUp: () =>
          when(() => getPosts(const GetPostsParams(forceRefresh: true)))
              .thenAnswer((_) async => const Result.failure(ServerFailure())),
      build: () => PostsBloc(getPosts),
      act: (bloc) => bloc.add(const PostsRefreshed()),
      expect: () => const [PostsFailure(ServerFailure())],
    );
  });
}
