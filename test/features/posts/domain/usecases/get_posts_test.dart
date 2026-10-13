import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_clean_starter/features/posts/domain/usecases/get_posts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/post_fixtures.dart';

class _MockPostRepository extends Mock implements PostRepository;

void main() {
  late _MockPostRepository repository;
  late GetPosts getPosts;

  setUp(() {
    repository = _MockPostRepository();
    getPosts = GetPosts(repository);
  });

  test('returns the repository result', () async {
    when(() => repository.getPosts())
        .thenAnswer((_) async => const Result.success([Fixtures.post]));

    final result = await getPosts(const GetPostsParams());

    expect(result, const Result.success([Fixtures.post]));
  });

  test('forwards forceRefresh', () async {
    when(() => repository.getPosts(forceRefresh: true))
        .thenAnswer((_) async => const Result.failure(NetworkFailure()));

    final result = await getPosts(const GetPostsParams(forceRefresh: true));

    expect(result.failureOrNull(), const NetworkFailure());
    verify(() => repository.getPosts(forceRefresh: true)).called(1);
  });

  test('params have value equality', () {
    expect(const GetPostsParams(), const GetPostsParams());
  });
}
