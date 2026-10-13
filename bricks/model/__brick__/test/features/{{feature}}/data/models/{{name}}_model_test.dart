import 'package:{{package}}/features/{{feature}}/data/models/{{name}}_model.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{name}}.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json = <String, dynamic>{'id': '1', 'name': 'name'};
  const model = {{name.pascalCase()}}Model(id: '1', name: 'name');
  const entity = {{name.pascalCase()}}(id: '1', name: 'name');

  group('{{name.pascalCase()}}Model', () {
    test('fromJson / toJson round-trip', () {
      expect({{name.pascalCase()}}Model.fromJson(json), model);
      expect(model.toJson(), json);
    });

    test('converts to and from the entity', () {
      expect(model.toEntity(), entity);
      expect({{name.pascalCase()}}Model.fromEntity(entity), model);
    });
  });
}
