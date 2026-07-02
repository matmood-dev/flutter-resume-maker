import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:resume_ai/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ResumeAIApp()));
    expect(find.text('ResumeAI'), findsOneWidget);
  });
}
