{{#params_custom}}import 'package:equatable/equatable.dart';
{{/params_custom}}{{#params_none}}import 'package:{{package}}/core/usecase/usecase.dart';
{{/params_none}}{{^params_none}}import 'package:{{package}}/core/usecase/usecase.dart';
{{/params_none}}import 'package:{{package}}/core/utils/typedefs.dart';
{{^returns_nothing}}import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
{{/returns_nothing}}import 'package:{{package}}/features/{{feature}}/domain/repositories/{{entity}}_repository.dart';

/// {{name.sentenceCase()}}.
class {{name.pascalCase()}} implements UseCase<{{#returns_entity}}{{entity.pascalCase()}}{{/returns_entity}}{{#returns_list}}List<{{entity.pascalCase()}}>{{/returns_list}}{{#returns_nothing}}void{{/returns_nothing}}, {{#params_none}}NoParams{{/params_none}}{{#params_id}}String{{/params_id}}{{#params_custom}}{{name.pascalCase()}}Params{{/params_custom}}> {
  /// Creates the use case.
  const {{name.pascalCase()}}(this._repository);

  final {{entity.pascalCase()}}Repository _repository;

  @override
  FutureResult<{{#returns_entity}}{{entity.pascalCase()}}{{/returns_entity}}{{#returns_list}}List<{{entity.pascalCase()}}>{{/returns_list}}{{#returns_nothing}}void{{/returns_nothing}}> call({{#params_none}}NoParams{{/params_none}}{{#params_id}}String{{/params_id}}{{#params_custom}}{{name.pascalCase()}}Params{{/params_custom}} params) => {{#params_none}}_repository.{{method}}(){{/params_none}}{{#params_id}}_repository.{{method}}(params){{/params_id}}{{#params_custom}}_repository.{{method}}(params){{/params_custom}};
}
{{#params_custom}}

/// Parameters for [{{name.pascalCase()}}]. Add fields and list them in [props].
final class {{name.pascalCase()}}Params extends Equatable {
  /// Creates the parameters.
  const {{name.pascalCase()}}Params();

  @override
  List<Object?> get props => const [];
}
{{/params_custom}}
