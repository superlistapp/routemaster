@TestOn('browser')
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/system_nav.dart';

import 'helpers.dart';

class _CountingHistoryProvider implements HistoryProvider {
  int backCount = 0;

  @override
  String get hash => '';

  @override
  void back() => backCount++;

  @override
  void forward() {}
}

void main() {
  testWidgets('pop() requests a single browser back', (tester) async {
    final previousProvider = SystemNav.historyProvider;
    final previousEnabled = SystemNav.enabled;
    final historyProvider = _CountingHistoryProvider();
    SystemNav.historyProvider = historyProvider;
    SystemNav.enabled = true;
    addTearDown(() {
      SystemNav.historyProvider = previousProvider;
      SystemNav.enabled = previousEnabled;
    });

    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPage<void>(child: PageOne()),
          '/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    await tester.pumpAndSettle();

    delegate.push('/two');
    await tester.pumpAndSettle();

    await delegate.pop();
    await tester.pumpAndSettle();

    expect(historyProvider.backCount, 1);
  });
}
