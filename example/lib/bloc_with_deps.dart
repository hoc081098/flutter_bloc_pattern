// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

import 'counter_bloc.dart';

class Dependencies {
  var _i = 0;

  Dependencies() {
    print('$this::init');
  }

  Future<String> loadSomething() =>
      Future.delayed(const Duration(milliseconds: 500), () => 'String ${_i++}');

  void dispose() {
    print('$this::dispose');
  }
}

class Bloc1 extends DisposeCallbackBaseBloc {
  final VoidAction load;

  final StateStream<String?> string$;

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
        .publishState(null);
    final connection = string$.connect();

    return Bloc1._(
      dispose: () async {
        await connection.cancel();
        await loadS.close();
        print('Bloc1::disposed');
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
