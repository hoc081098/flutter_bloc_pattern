import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import 'flutter_bloc_pattern_test.mocks.dart';

abstract class BaseBlocProvider {
  BaseBloc call();
}

// ignore: must_be_immutable
class BlocCaptor<T extends BaseBloc> extends StatelessWidget {
  static const Key captorKey = Key('BlocCaptor');

  late T bloc;

  BlocCaptor() : super(key: captorKey);

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<T>(context);
    return Container();
  }
}

@GenerateMocks(
  [BaseBlocProvider],
  customMocks: [
    MockSpec<BaseBloc>(as: #MockBloc),
    MockSpec<BaseBloc>(as: #BlocA),
    MockSpec<BaseBloc>(as: #BlocB),
    MockSpec<DisposeCallbackBaseBloc>(as: #BlocC),
  ],
)
void main() {
  group('Flutter bloc pattern provider', () {
    testWidgets('passes a bloc down to its descendants',
        (WidgetTester tester) async {
      final bloc = MockBloc();
      when(bloc.dispose()).thenReturn(null);

      final widget = BlocProvider<MockBloc>(
        initBloc: () => bloc,
        child: BlocCaptor<MockBloc>(),
      );

      await tester.pumpWidget(widget);

      final captor = tester.firstWidget<BlocCaptor<MockBloc>>(
        find.byKey(BlocCaptor.captorKey),
      );

      expect(captor.bloc, bloc);
    });

    testWidgets('calls initBloc only once', (tester) async {
      final builder = MockBaseBlocProvider();
      final bloc = MockBloc();
      when(builder.call()).thenReturn(bloc);
      when(bloc.dispose()).thenReturn(null);

      await tester.pumpWidget(
        BlocProvider<BaseBloc>(
          child: Container(),
          initBloc: builder,
        ),
      );
      await tester.pumpWidget(
        BlocProvider<BaseBloc>(
          child: Container(),
          initBloc: builder,
        ),
      );
      await tester.pumpWidget(Container());

      verify(builder()).called(1);
    });

    testWidgets('dispose', (tester) async {
      final bloc = MockBloc();
      when(bloc.dispose()).thenReturn(null);

      final widget = BlocProvider<MockBloc>(
        initBloc: () => bloc,
        child: Container(),
      );
      await tester.pumpWidget(widget);
      await tester.pumpWidget(Container());
      verify(bloc.dispose()).called(1);
    });
  });

  group('RxStreamBuilder', () {
    test('Get initial data', () {
      expect(
        RxStreamBuilder.getInitialData(1, Stream.empty()),
        1,
      );
      expect(
        RxStreamBuilder.getInitialData(1, Stream.fromIterable([2, 3, 4])),
        1,
      );

      //
      //

      expect(
        RxStreamBuilder.getInitialData(1, BehaviorSubject.seeded(2)),
        1,
      );
      expect(
        RxStreamBuilder.getInitialData(null, BehaviorSubject.seeded(2)),
        2,
      );
      expect(
        RxStreamBuilder.getInitialData(
          null,
          BehaviorSubject<int>()..addError('Error'),
        ),
        isNull,
      );

      //
      //

      expect(
        RxStreamBuilder.getInitialData(
          null,
          ReplaySubject(maxSize: 2)..add(1)..add(2)..add(3)..add(4),
        ),
        4,
      );
      expect(
        RxStreamBuilder.getInitialData(
          null,
          ReplaySubject(maxSize: 2),
        ),
        isNull,
      );

      //
      //

      expect(
        RxStreamBuilder.getInitialData(
          null,
          Stream.empty().shareValueDistinct(2),
        ),
        2,
      );
      expect(
        RxStreamBuilder.getInitialData(
          null,
          Stream.empty().publishValueDistinct(3),
        ),
        3,
      );
    });
  });

  group('BlocProviders', () {
    testWidgets('Empty bloc providers returns child', (tester) async {
      await tester.pumpWidget(
        BlocProviders(
          child: Text(
            'Hello',
            textDirection: TextDirection.ltr,
          ),
          blocProviders: [],
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('Children can only access parent providers', (tester) async {
      final isBlocProviderError = throwsA(isA<BlocProviderError>());

      final k1 = GlobalKey();
      final k2 = GlobalKey();
      final k3 = GlobalKey();
      final blocA = BlocA();
      final blocB = BlocB();
      final blocC = BlocC();
      final keyChild = GlobalKey();

      when(blocA.dispose()).thenReturn(null);
      when(blocB.dispose()).thenReturn(null);
      when(blocC.dispose()).thenReturn(null);

      final p1 = BlocProvider<BlocA>(key: k1, initBloc: () => blocA);
      final p2 = BlocProvider<BlocB>(key: k2, initBloc: () => blocB);
      final p3 = BlocProvider<BlocC>(key: k3, initBloc: () => blocC);

      await tester.pumpWidget(
        BlocProviders(
          blocProviders: [p1, p2, p3],
          child: Text(
            'Foo',
            key: keyChild,
            textDirection: TextDirection.ltr,
          ),
        ),
      );

      expect(find.text('Foo'), findsOneWidget);

      // p1 cannot access to p1, p2 and p3
      expect(
        () => BlocProvider.of<BlocA>(k1.currentContext!),
        isBlocProviderError,
      );
      expect(
        () => BlocProvider.of<BlocB>(k1.currentContext!),
        isBlocProviderError,
      );
      expect(
        () => BlocProvider.of<BlocC>(k1.currentContext!),
        isBlocProviderError,
      );

      // p2 can access only p1
      expect(BlocProvider.of<BlocA>(k2.currentContext!), blocA);
      expect(
        () => BlocProvider.of<BlocB>(k2.currentContext!),
        isBlocProviderError,
      );
      expect(
        () => BlocProvider.of<BlocC>(k2.currentContext!),
        isBlocProviderError,
      );

      // p3 can access both p1 and p2
      expect(BlocProvider.of<BlocA>(k3.currentContext!), blocA);
      expect(BlocProvider.of<BlocB>(k3.currentContext!), blocB);
      expect(
        () => BlocProvider.of<BlocC>(k3.currentContext!),
        isBlocProviderError,
      );

      // the child can access them all
      expect(BlocProvider.of<BlocA>(keyChild.currentContext!), blocA);
      expect(BlocProvider.of<BlocB>(keyChild.currentContext!), blocB);
      expect(BlocProvider.of<BlocC>(keyChild.currentContext!), blocC);
    });
  });
}
