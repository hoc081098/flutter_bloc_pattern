import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

//ignore_for_file: close_sinks
class CounterBloc implements BaseBloc {
  ///
  /// Inputs
  ///
  final void Function() increment;

  ///
  /// Outputs
  ///
  final ValueObservable<int> state;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  CounterBloc._(
    this._dispose, {
    @required this.increment,
    @required this.state,
  });

  factory CounterBloc() {
    final incrementController = PublishSubject<void>();
    final state = incrementController
        .scan<int>((acc, _, __) => acc + 1, 0)
        .shareValue(seedValue: 0);

    return CounterBloc._(
      incrementController.close,
      increment: () => incrementController.add(null),
      state: state,
    );
  }

  @override
  void dispose() => _dispose();
}
