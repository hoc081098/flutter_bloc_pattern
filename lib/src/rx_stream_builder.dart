import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'error.dart';

// ignore_for_file: unnecessary_null_comparison

/// Signature for strategies that build widgets based on asynchronous interaction.
typedef RxWidgetBuilder<T> = Widget Function(BuildContext context, T data);

/// Rx stream builder that will pre-populate the streams initial data if the
/// given stream is an stream that holds the streams current value such
/// as a [ValueStream] or a [ReplayStream]
class RxStreamBuilder<T> extends StatefulWidget {
  final RxWidgetBuilder<T> _builder;
  final ValueStream<T> _stream;

  /// Creates a new [RxStreamBuilder] that builds itself based on the latest
  /// snapshot of interaction with the specified [stream] and whose build
  /// strategy is given by [builder].
  ///
  /// The [initialData] is used to create the initial snapshot.
  /// See [StreamBuilder.initialData].
  ///
  /// The [builder] must not be null. It must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  RxStreamBuilder({
    Key? key,
    required RxWidgetBuilder<T> builder,
    required ValueStream<T> stream,
  })   : assert(builder != null),
        assert(stream != null),
        _builder = builder,
        _stream = stream;

  @override
  _RxStreamBuilderState<T> createState() => _RxStreamBuilderState();

  /// Get latest value from stream or return `null`.
  @visibleForTesting
  static T getInitialData<T>(ValueStream<T> stream) {
    if (stream.hasValue) {
      return stream.value;
    }
    throw ArgumentError.value(stream, 'stream', 'does not have value');
  }
}

class _RxStreamBuilderState<T> extends State<RxStreamBuilder<T>> {
  late T value;
  StreamSubscription<T>? subscription;

  @override
  void initState() {
    super.initState();
    subscribe();
  }

  @override
  void didUpdateWidget(covariant RxStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._stream != widget._stream) {
      unsubscribe();
      subscribe();
    }
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget._builder(context, value);

  void subscribe() {
    value = RxStreamBuilder.getInitialData(widget._stream);

    subscription = widget._stream.listen(
      (v) => setState(() => value = v),
      onError: (Object e, StackTrace s) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: e,
            stack: s,
            library: 'flutter_bloc_pattern',
          ),
        );
        throw UnhandledStreamError(e, s);
      },
    );
  }

  void unsubscribe() {
    subscription?.cancel();
    subscription = null;
  }
}
