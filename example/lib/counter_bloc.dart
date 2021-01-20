import 'dart:async';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class CounterBloc extends DisposeCallbackBaseBloc {
  /// Inputs
  final void Function() increment;

  /// Outputs
  final DistinctValueStream<int> state;

  CounterBloc._({
    required void Function() dispose,
    required this.increment,
    required this.state,
  }) : super(dispose);

  factory CounterBloc() {
    // ignore: close_sinks
    final incrementController = StreamController<void>();

    final state = incrementController.stream
        .scan<int>((acc, _, __) => acc! + 1, 0)
        .publishValueDistinct(0);
    final connection = state.connect();

    return CounterBloc._(
      dispose: () async {
        await connection.cancel();
        await incrementController.close();
        print('CounterBloc::disposed');
      },
      increment: () => incrementController.add(null),
      state: state,
    );
  }
}
