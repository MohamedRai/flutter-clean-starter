import 'package:bloc_test/bloc_test.dart';
import 'package:{{package}}/core/bloc/async_state.dart';
import 'package:{{package}}/core/domain/result.dart';
import 'package:{{package}}/core/error/failures.dart';
import 'package:{{package}}/core/usecase/usecase.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
import 'package:{{package}}/features/{{feature}}/domain/usecases/get_{{entity}}_list.dart';
import 'package:{{package}}/features/{{feature}}/presentation/cubit/{{entity}}_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGet{{entity.pascalCase()}}List extends Mock implements Get{{entity.pascalCase()}}List;

void main() {
  late _MockGet{{entity.pascalCase()}}List get{{entity.pascalCase()}}List;
  const items = [{{entity.pascalCase()}}(id: '1', name: 'name')];

  setUp(() => get{{entity.pascalCase()}}List = _MockGet{{entity.pascalCase()}}List());

  blocTest<{{entity.pascalCase()}}ListCubit, AsyncState<List<{{entity.pascalCase()}}>>>(
    'emits loading then success',
    setUp: () => when(
      () => get{{entity.pascalCase()}}List(const NoParams()),
    ).thenAnswer((_) async => const Result.success(items)),
    build: () => {{entity.pascalCase()}}ListCubit(get{{entity.pascalCase()}}List),
    act: (cubit) => cubit.load(const NoParams()),
    expect: () => const [
      AsyncLoading<List<{{entity.pascalCase()}}>>(),
      AsyncSuccess<List<{{entity.pascalCase()}}>>(items),
    ],
  );

  blocTest<{{entity.pascalCase()}}ListCubit, AsyncState<List<{{entity.pascalCase()}}>>>(
    'emits loading then failure',
    setUp: () => when(
      () => get{{entity.pascalCase()}}List(const NoParams()),
    ).thenAnswer((_) async => const Result.failure(NetworkFailure())),
    build: () => {{entity.pascalCase()}}ListCubit(get{{entity.pascalCase()}}List),
    act: (cubit) => cubit.load(const NoParams()),
    expect: () => const [
      AsyncLoading<List<{{entity.pascalCase()}}>>(),
      AsyncFailure<List<{{entity.pascalCase()}}>>(NetworkFailure()),
    ],
  );
}
