import 'package:{{package}}/core/data/domain_convertible.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{entity}}_model.freezed.dart';
part '{{entity}}_model.g.dart';

/// JSON representation of [{{entity.pascalCase()}}].
@freezed
abstract class {{entity.pascalCase()}}Model with _${{entity.pascalCase()}}Model implements DomainConvertible<{{entity.pascalCase()}}> {
  /// Creates the model.
  const factory {{entity.pascalCase()}}Model({required String id, required String name}) =
      _{{entity.pascalCase()}}Model;

  const {{entity.pascalCase()}}Model._();

  /// Decodes a JSON object.
  factory {{entity.pascalCase()}}Model.fromJson(Map<String, dynamic> json) =>
      _${{entity.pascalCase()}}ModelFromJson(json);

  /// Builds the model from a domain [entity].
  factory {{entity.pascalCase()}}Model.fromEntity({{entity.pascalCase()}} entity) =>
      {{entity.pascalCase()}}Model(id: entity.id, name: entity.name);

  @override
  {{entity.pascalCase()}} toEntity() => {{entity.pascalCase()}}(id: id, name: name);
}
