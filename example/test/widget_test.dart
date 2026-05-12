import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Demo app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DemoApp());
    await tester.pump();

    expect(find.text('ProgressBar 增强功能演示'), findsOneWidget);
    expect(find.text('滑块形状 (thumbShape)'), findsOneWidget);
  });
}
