import 'package:{{package}}/features/{{feature}}/data/models/{{entity}}_model.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json = <String, dynamic>{'id': '1', 'name': 'name'};
  const model = {{entity.pascalCase()}}Model(id: '1', name: 'name');
  const entity = {{entity.pascalCase()}}(id: '1', name: 'name');

  group('{{entity.pascalCase()}}Model', () {
    test('fromJson / toJson round-trip', () {
      expect({{entity.pascalCase()}}Model.fromJson(json), model);
      expect(model.toJson(), json);
    });

    test('converts to and from the entity', () {
      expect(model.toEntity(), entity);
      expect({{entity.pascalCase()}}Model.fromEntity(entity), model);
    });
  });
}
