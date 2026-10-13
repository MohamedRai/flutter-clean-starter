import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_clean_starter/core/bloc/async_cubit.dart';
import 'package:flutter_clean_starter/core/bloc/async_state.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_test/flutter_test.dart';

class _DoubleCubit extends AsyncCubit<int, int> {
  bool fail = false;

  @override
  FutureResult<int> execute(int params) async => fail
      ? const Result.failure(NetworkFailure())
      : Result.success(params * 2);
}

void main() {
  group('AsyncCubit', () {
    blocTest<_DoubleCubit, AsyncState<int>>(
      'emits loading then success',
      build: _DoubleCubit.new,
      act: (cubit) => cubit.load(21),
      expect: () => const [AsyncLoading<int>(), AsyncSuccess<int>(42)],
    );

    blocTest<_DoubleCubit, AsyncState<int>>(
      'emits loading then failure',
      build: () => _DoubleCubit()..fail = true,
      act: (cubit) => cubit.load(1),
      expect: () => const [
        AsyncLoading<int>(),
        AsyncFailure<int>(NetworkFailure()),
      ],
    );

    blocTest<_DoubleCubit, AsyncState<int>>(
      'silent load skips the loading state',
      build: _DoubleCubit.new,
      act: (cubit) => cubit.load(1, silent: true),
      expect: () => const [AsyncSuccess<int>(2)],
    );

    blocTest<_DoubleCubit, AsyncState<int>>(
      'retry replays the last params; no-op before any load',
      build: _DoubleCubit.new,
      act: (cubit) async {
        await cubit.retry();
        await cubit.load(5);
        await cubit.retry(silent: true);
      },
      expect: () => const [
        AsyncLoading<int>(),
        AsyncSuccess<int>(10),
        // Equal state is not re-emitted by Cubit.
      ],
    );

    blocTest<_DoubleCubit, AsyncState<int>>(
      'reset returns to initial',
      build: _DoubleCubit.new,
      act: (cubit) async {
        await cubit.load(1);
        cubit.reset();
      },
      expect: () => const [
        AsyncLoading<int>(),
        AsyncSuccess<int>(2),
        AsyncInitial<int>(),
      ],
    );
  });
}
