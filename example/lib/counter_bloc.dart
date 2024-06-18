import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class CounterBloc extends DisposeCallbackBaseBloc {
  /// Inputs
  final VoidAction increment;

  /// Outputs
  final StateStream<int> state;

  CounterBloc._({
    required VoidAction dispose,
    required this.increment,
    required this.state,
  }) : super(dispose);

  factory CounterBloc() {
    final incrementController = StreamController<void>();

    final state$ = incrementController.stream
        .scan<int>((acc, _, __) => acc + 1, 0)
        .publishState(0);

    return CounterBloc._(
      dispose: DisposeBag([incrementController, state$.connect()]).dispose,
      increment: incrementController.addNull,
      state: state$,
    );
  }
}
