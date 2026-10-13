import 'package:bloc_test/bloc_test.dart';
import 'package:{{package}}/features/{{feature}}/presentation/bloc/{{name}}_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts in {{name.pascalCase()}}Initial', () {
    expect({{name.pascalCase()}}Bloc().state, const {{name.pascalCase()}}Initial());
  });

  blocTest<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
    'emits loading then success on {{name.pascalCase()}}Started',
    build: {{name.pascalCase()}}Bloc.new,
    act: (bloc) => bloc.add(const {{name.pascalCase()}}Started()),
    expect: () => const [{{name.pascalCase()}}Loading(), {{name.pascalCase()}}Success()],
  );
}
