import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_clean_starter/features/posts/domain/usecases/get_post_by_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/post_fixtures.dart';

class _MockPostRepository extends Mock implements PostRepository;

void main() {
  late _MockPostRepository repository;
  late GetPostById getPostById;

  setUp(() {
    repository = _MockPostRepository();
    getPostById = GetPostById(repository);
  });

  test('loads the post with the given id', () async {
    when(() => repository.getPostById(1))
        .thenAnswer((_) async => const Result.success(Fixtures.post));

    final result = await getPostById(const GetPostByIdParams(id: 1));

    expect(result, const Result.success(Fixtures.post));
    verify(() => repository.getPostById(1)).called(1);
  });

  test('params have value equality', () {
    expect(const GetPostByIdParams(id: 1), const GetPostByIdParams(id: 1));
  });
}
