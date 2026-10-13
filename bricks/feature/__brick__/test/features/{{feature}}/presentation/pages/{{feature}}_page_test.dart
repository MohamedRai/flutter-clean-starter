import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{package}}/core/bloc/async_state.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
import 'package:{{package}}/features/{{feature}}/presentation/cubit/{{entity}}_list_cubit.dart';
import 'package:{{package}}/features/{{feature}}/presentation/pages/{{feature}}_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockCubit extends MockCubit<AsyncState<List<{{entity.pascalCase()}}>>>
    implements {{entity.pascalCase()}}ListCubit;

void main() {
  testWidgets('lists items', (tester) async {
    final cubit = _MockCubit();
    when(() => cubit.state).thenReturn(
      const AsyncSuccess([{{entity.pascalCase()}}(id: '1', name: 'first')]),
    );
    await tester.pumpApp(
      BlocProvider<{{entity.pascalCase()}}ListCubit>.value(
        value: cubit,
        child: const {{feature.pascalCase()}}Page(title: 'Title'),
      ),
    );
    expect(find.text('first'), findsOneWidget);
  });
}
