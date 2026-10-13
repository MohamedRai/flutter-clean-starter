import 'package:bloc_test/bloc_test.dart';
import 'package:{{package}}/features/{{feature}}/presentation/cubit/{{name}}_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts in {{name.pascalCase()}}Initial', () {
    expect({{name.pascalCase()}}Cubit().state, const {{name.pascalCase()}}Initial());
  });

  blocTest<{{name.pascalCase()}}Cubit, {{name.pascalCase()}}State>(
    'load emits loading then success',
    build: {{name.pascalCase()}}Cubit.new,
    act: (cubit) => cubit.load(),
    expect: () => const [{{name.pascalCase()}}Loading(), {{name.pascalCase()}}Success()],
  );
}
