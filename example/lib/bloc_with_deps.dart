import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

import 'counter_bloc.dart';

class Dependencies {
  var _i = 0;

  Dependencies() {
    debugPrint('$this::init');
  }

  Future<String> loadSomething() =>
      Future.delayed(const Duration(milliseconds: 500), () => 'String ${_i++}');

  void dispose() {
    debugPrint('$this::dispose');
  }
}

class Bloc1 extends DisposeCallbackBaseBloc {
  final VoidAction load;

  final StateStream<String?> string$;

  Bloc1._({
    required VoidAction dispose,
    required this.load,
    required this.string$,
  }) : super(dispose);

  factory Bloc1(Dependencies dependencies) {
    final loadS = StreamController<void>();

    final string$ = loadS.stream
        .switchMap((value) => Rx.fromCallable(dependencies.loadSomething))
        .cast<String?>()
        .publishState(null);

    return Bloc1._(
      dispose: DisposeBag([loadS, string$.connect()]).dispose,
      load: () => loadS.add(null),
      string$: string$,
    );
  }
}

class Bloc2 implements BaseBloc {
  Bloc2(CounterBloc bloc) {
    debugPrint('$this::init with counter bloc $bloc');
  }

  @override
  void dispose() {
    debugPrint('$this::dispose');
  }
}
