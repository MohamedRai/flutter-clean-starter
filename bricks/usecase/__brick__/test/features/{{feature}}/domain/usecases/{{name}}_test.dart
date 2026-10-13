import 'package:{{package}}/core/domain/result.dart';
{{#params_none}}import 'package:{{package}}/core/usecase/usecase.dart';
{{/params_none}}{{^returns_nothing}}import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
{{/returns_nothing}}import 'package:{{package}}/features/{{feature}}/domain/repositories/{{entity}}_repository.dart';
import 'package:{{package}}/features/{{feature}}/domain/usecases/{{name}}.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements {{entity.pascalCase()}}Repository;

void main() {
  test('delegates to {{entity.pascalCase()}}Repository.{{method}}', () async {
    final repository = _MockRepository();
    when(
      () => {{#params_none}}repository.{{method}}(){{/params_none}}{{#params_id}}repository.{{method}}('1'){{/params_id}}{{#params_custom}}repository.{{method}}(const {{name.pascalCase()}}Params()){{/params_custom}},
    ).thenAnswer((_) async => const Result<{{#returns_entity}}{{entity.pascalCase()}}{{/returns_entity}}{{#returns_list}}List<{{entity.pascalCase()}}>{{/returns_list}}{{#returns_nothing}}void{{/returns_nothing}}>.success({{#returns_entity}}const {{entity.pascalCase()}}(id: '1', name: 'name'){{/returns_entity}}{{#returns_list}}const [{{entity.pascalCase()}}(id: '1', name: 'name')]{{/returns_list}}{{#returns_nothing}}null{{/returns_nothing}}));

    final result = await {{name.pascalCase()}}(repository)({{#params_none}}const NoParams(){{/params_none}}{{#params_id}}'1'{{/params_id}}{{#params_custom}}const {{name.pascalCase()}}Params(){{/params_custom}});

    expect(result, const Result<{{#returns_entity}}{{entity.pascalCase()}}{{/returns_entity}}{{#returns_list}}List<{{entity.pascalCase()}}>{{/returns_list}}{{#returns_nothing}}void{{/returns_nothing}}>.success({{#returns_entity}}const {{entity.pascalCase()}}(id: '1', name: 'name'){{/returns_entity}}{{#returns_list}}const [{{entity.pascalCase()}}(id: '1', name: 'name')]{{/returns_list}}{{#returns_nothing}}null{{/returns_nothing}}));
    verify(() => {{#params_none}}repository.{{method}}(){{/params_none}}{{#params_id}}repository.{{method}}('1'){{/params_id}}{{#params_custom}}repository.{{method}}(const {{name.pascalCase()}}Params()){{/params_custom}}).called(1);
  });
}
