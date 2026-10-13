import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_clean_starter/core/bloc/async_state.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_clean_starter/features/posts/domain/usecases/get_post_by_id.dart';
import 'package:flutter_clean_starter/features/posts/presentation/cubit/post_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/post_fixtures.dart';

class _MockGetPostById extends Mock implements GetPostById;

void main() {
  late _MockGetPostById getPostById;

  setUp(() => getPostById = _MockGetPostById());

  blocTest<PostDetailCubit, AsyncState<Post>>(
    'loads the post with the given id',
    setUp: () =>
        when(() => getPostById(const GetPostByIdParams(id: 1)))
            .thenAnswer((_) async => const Result.success(Fixtures.post)),
    build: () => PostDetailCubit(getPostById),
    act: (cubit) => cubit.load(1),
    expect: () => const [
      AsyncLoading<Post>(),
      AsyncSuccess<Post>(Fixtures.post),
    ],
  );

  blocTest<PostDetailCubit, AsyncState<Post>>(
    'emits the failure',
    setUp: () =>
        when(() => getPostById(const GetPostByIdParams(id: 9)))
            .thenAnswer((_) async => const Result.failure(NotFoundFailure())),
    build: () => PostDetailCubit(getPostById),
    act: (cubit) => cubit.load(9),
    expect: () => const [
      AsyncLoading<Post>(),
      AsyncFailure<Post>(NotFoundFailure()),
    ],
  );
}
