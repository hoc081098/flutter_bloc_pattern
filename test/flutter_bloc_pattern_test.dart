import 'dart:async';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import 'flutter_bloc_pattern_test.mocks.dart';

abstract class BaseBlocProvider {
  BaseBloc call(BuildContext context);
}

abstract class Dispose {
  void call();
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
    MockSpec<Dispose>(),
  ],
)
void main() {
  group('Base and Error', () {
    test('DisposeCallbackBaseBloc', () {
      final dispose = MockDispose();
      when(dispose.call()).thenReturn(null);

      verifyNever(dispose.call());
      DisposeCallbackBaseBloc(dispose).dispose();

      verify(dispose.call()).called(1);
    });

    test('BlocProviderError', () {
      expect(
        BlocProviderError(null).toString(),
        '''Error: please specify type instead of using dynamic when calling BlocProvider.of<T>() or context.bloc<T>() method.''',
      );

      expect(
        BlocProviderError(BaseBloc).toString(),
        '''Error: No BaseBloc found. To fix, please try:
  * Wrapping your MaterialApp with the BlocProvider<BaseBloc>, 
  rather than an individual Route.
  * Providing full type information to BlocProvider<BaseBloc>, BlocProvider.of<BaseBloc> and context.bloc<BaseBloc>() method
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_bloc_pattern/issues/new
      ''',
      );
    });
  });

  group('BlocProvider', () {
    testWidgets('passes a bloc down to its descendants',
        (WidgetTester tester) async {
      final bloc = MockBloc();
      when(bloc.dispose()).thenReturn(null);

      final widget = BlocProvider<MockBloc>(
        initBloc: (_) => bloc,
        child: BlocCaptor<MockBloc>(),
      );

      await tester.pumpWidget(widget);

      final captor = tester.firstWidget<BlocCaptor<MockBloc>>(
        find.byKey(BlocCaptor.captorKey),
      );

      expect(captor.bloc, bloc);
    });

    testWidgets('calls initBloc only once, on first access', (tester) async {
      final initBloc = MockBaseBlocProvider();
      final bloc = MockBloc();

      when(initBloc.call(any)).thenReturn(bloc);
      when(bloc.dispose()).thenReturn(null);

      late BuildContext context;
      await tester.pumpWidget(
        BlocProvider<BaseBloc>(
          child: Builder(
            builder: (c) {
              context = c;
              return Container();
            },
          ),
          initBloc: initBloc,
        ),
      );

      verifyNever(initBloc.call(any));
      expect(context.bloc<BaseBloc>(), bloc);
      verify(initBloc(any)).called(1);
    });

    testWidgets('dispose', (tester) async {
      final bloc = MockBloc();
      when(bloc.dispose()).thenReturn(null);

      late BuildContext context;
      await tester.pumpWidget(
        BlocProvider<MockBloc>(
          initBloc: (_) => bloc,
          child: Builder(
            builder: (c) {
              context = c;
              return Container();
            },
          ),
        ),
      );

      context.bloc<MockBloc>();
      await tester.pumpWidget(Container());

      verify(bloc.dispose()).called(1);
    });
  });

  group('RxStreamBuilder', () {
    test('Get initial data', () {
      expect(
        RxStreamBuilder.getInitialData<int>(1, Stream.empty()),
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
        RxStreamBuilder.getInitialData<int>(
          null,
          ReplaySubject(maxSize: 2)..add(1)..add(2)..add(3)..add(4),
        ),
        4,
      );
      expect(
        RxStreamBuilder.getInitialData<int>(
          null,
          ReplaySubject(maxSize: 2),
        ),
        isNull,
      );

      //
      //

      expect(
        RxStreamBuilder.getInitialData<int>(
          null,
          Stream<int>.empty().shareValueDistinct(2),
        ),
        2,
      );
      expect(
        RxStreamBuilder.getInitialData<int>(
          null,
          Stream<int>.empty().publishValueDistinct(3),
        ),
        3,
      );
    });

    testWidgets('Build with latest value from Stream', (tester) async {
      final controller = StreamController<String>();
      final seeded = 'Seeded';
      final event1 = 'Emitted 1';
      final event2 = 'Emitted 2';
      final events = <String>[];

      await tester.pumpWidget(
        RxStreamBuilder<String>(
          stream: controller.stream.shareValueDistinct(seeded),
          builder: (context, s) {
            events.add(s!);

            return Text(s, textDirection: TextDirection.ltr);
          },
        ),
      );
      expect(find.text(seeded), findsOneWidget);

      controller.add(event1);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text(event1), findsOneWidget);

      controller.add(event2);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text(event2), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      expect(events, [seeded, event1, event2]);
    });

    testWidgets('report error if has error', (tester) async {
      final completer = Completer<Object>.sync();
      FlutterError.onError =
          (errorDetails) => completer.complete(errorDetails.exception);

      final controller = StreamController<String>();
      final seeded = 'Seeded';

      await tester.pumpWidget(
        RxStreamBuilder<String>(
          stream: controller.stream.shareValueSeeded(seeded),
          builder: (context, s) => Text(s!, textDirection: TextDirection.ltr),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text(seeded), findsOneWidget);

      controller.addError(Exception());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final error = await completer.future;
      print(error);
      expect(
        error,
        isA<UnhandledStreamError>().having(
          (e) => e.toString(),
          'toString()',
          '''Unhandled error from Stream: Exception.
You should use one of following methods to handle error before passing stream to RxStreamBuilder:
  * stream.handleError((e, s) { })
  * stream.onErrorReturn(value)
  * stream.onErrorReturnWith((e) => value)
  * stream.onErrorResumeNext(otherStream)
  * stream.onErrorResume((e) => otherStream)
  * stream.transform(
        StreamTransformer.fromHandlers(handleError: (e, s, sink) {}))
  ...
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_bloc_pattern/issues/new
''',
        ),
      );
    });
  });

  group('BlocProviders', () {
    test('Empty bloc providers throws AssertError', () {
      expect(
        () => BlocProviders(
          child: Text(
            'Hello',
            textDirection: TextDirection.ltr,
          ),
          blocProviders: [],
        ),
        throwsAssertionError,
      );
    });

    testWidgets('Children can only access parent providers', (tester) async {
      final isBlocProviderError = (Type type) {
        final string = '''Error: No $type found. To fix, please try:
  * Wrapping your MaterialApp with the BlocProvider<$type>, 
  rather than an individual Route.
  * Providing full type information to BlocProvider<$type>, BlocProvider.of<$type> and context.bloc<$type>() method
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_bloc_pattern/issues/new
      ''';

        return throwsA(
          isA<BlocProviderError>().having(
            (e) => e.toString(),
            'toString()',
            string,
          ),
        );
      };

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

      final p1 = BlocProvider<BlocA>(key: k1, initBloc: (_) => blocA);
      final p2 = BlocProvider<BlocB>(key: k2, initBloc: (_) => blocB);
      final p3 = BlocProvider<BlocC>(key: k3, initBloc: (_) => blocC);

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
        isBlocProviderError(BlocA),
      );
      expect(
        () => BlocProvider.of<BlocB>(k1.currentContext!),
        isBlocProviderError(BlocB),
      );
      expect(
        () => BlocProvider.of<BlocC>(k1.currentContext!),
        isBlocProviderError(BlocC),
      );

      // p2 can access only p1
      expect(BlocProvider.of<BlocA>(k2.currentContext!), blocA);
      expect(
        () => BlocProvider.of<BlocB>(k2.currentContext!),
        isBlocProviderError(BlocB),
      );
      expect(
        () => BlocProvider.of<BlocC>(k2.currentContext!),
        isBlocProviderError(BlocC),
      );

      // p3 can access both p1 and p2
      expect(BlocProvider.of<BlocA>(k3.currentContext!), blocA);
      expect(BlocProvider.of<BlocB>(k3.currentContext!), blocB);
      expect(
        () => BlocProvider.of<BlocC>(k3.currentContext!),
        isBlocProviderError(BlocC),
      );

      // the child can access them all
      expect(BlocProvider.of<BlocA>(keyChild.currentContext!), blocA);
      expect(BlocProvider.of<BlocB>(keyChild.currentContext!), blocB);
      expect(BlocProvider.of<BlocC>(keyChild.currentContext!), blocC);
    });
  });
}
