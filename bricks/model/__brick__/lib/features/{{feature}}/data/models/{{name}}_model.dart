import 'package:{{package}}/core/data/domain_convertible.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{name}}.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{name}}_model.freezed.dart';
part '{{name}}_model.g.dart';

/// JSON representation of [{{name.pascalCase()}}].
@freezed
abstract class {{name.pascalCase()}}Model with _${{name.pascalCase()}}Model implements DomainConvertible<{{name.pascalCase()}}> {
  /// Creates the model.
  const factory {{name.pascalCase()}}Model({required String id, required String name}) =
      _{{name.pascalCase()}}Model;

  const {{name.pascalCase()}}Model._();

  /// Decodes a JSON object.
  factory {{name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) =>
      _${{name.pascalCase()}}ModelFromJson(json);

  /// Builds the model from a domain [entity].
  factory {{name.pascalCase()}}Model.fromEntity({{name.pascalCase()}} entity) =>
      {{name.pascalCase()}}Model(id: entity.id, name: entity.name);

  @override
  {{name.pascalCase()}} toEntity() => {{name.pascalCase()}}(id: id, name: name);
}
