import 'package:{{package}}/features/{{feature}}/presentation/pages/{{name}}_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows its title', (tester) async {
    await tester.pumpApp(const {{name.pascalCase()}}Page(title: 'Title'));
    expect(find.text('Title'), findsOneWidget);
  });
}
