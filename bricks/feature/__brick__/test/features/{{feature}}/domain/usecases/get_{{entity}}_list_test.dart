import 'package:{{package}}/core/domain/result.dart';
import 'package:{{package}}/core/usecase/usecase.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
import 'package:{{package}}/features/{{feature}}/domain/repositories/{{entity}}_repository.dart';
import 'package:{{package}}/features/{{feature}}/domain/usecases/get_{{entity}}_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements {{entity.pascalCase()}}Repository;

void main() {
  test('returns the repository result', () async {
    final repository = _MockRepository();
    const items = [{{entity.pascalCase()}}(id: '1', name: 'name')];
    when(repository.getAll).thenAnswer((_) async => const Result.success(items));

    final result = await Get{{entity.pascalCase()}}List(repository)(const NoParams());

    expect(result, const Result.success(items));
  });
}
