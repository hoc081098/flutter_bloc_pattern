import 'dart:async';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:example/counter_bloc.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class Dependencies {
  Dependencies() {
    print('$this::init');
  }

  Future<String> loadSomething() =>
      Future.delayed(const Duration(seconds: 1), () => 'A string');

  void dispose() {
    print('$this::dispose');
  }
}

class Bloc1 extends DisposeCallbackBaseBloc {
  final void Function() load;

  final DistinctValueStream<String?> string$;

  Bloc1._({
    required void Function() dispose,
    required this.load,
    required this.string$,
  }) : super(dispose);

  factory Bloc1(Dependencies dependencies) {
    // ignore: close_sinks
    final loadS = StreamController<void>();

    final string$ = loadS.stream
        .switchMap((value) => Rx.fromCallable(dependencies.loadSomething))
        .cast<String?>()
        .publishValueDistinct(null);
    final connection = string$.connect();

    return Bloc1._(
      dispose: () async {
        await connection.cancel();
        await loadS.close();
      },
      load: () => loadS.add(null),
      string$: string$,
    );
  }
}

class Bloc2 implements BaseBloc {
  Bloc2(CounterBloc bloc) {
    print('$this::init with counter bloc $bloc');
  }

  @override
  void dispose() {
    print('$this::dispose');
  }
}
