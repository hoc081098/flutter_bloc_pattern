import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

import 'error.dart';

/// Signature for strategies that build widgets based on asynchronous interaction.
typedef RxWidgetBuilder<T> = Widget Function(BuildContext context, T data);

/// Rx stream builder that will pre-populate the streams initial data if the
/// given stream is an stream that holds the streams current value such
/// as a [ValueStream] or a [ReplayStream]
class RxStreamBuilder<T> extends StatefulWidget {
  /// @experimental
  /// Set to `true` to check invalid state caused by [StateStream]s.
  ///
  /// ## Example
  /// ```dart
  /// // enabled when running in debug or profile mode
  /// RxStreamBuilder.checkStateStreamEnabled = !kReleaseMode;
  /// ```
  static var checkStateStreamEnabled = false;

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
  const RxStreamBuilder({
    Key? key,
    required ValueStream<T> stream,
    required RxWidgetBuilder<T> builder,
  })  : _builder = builder,
        _stream = stream,
        super(key: key);

  @override
  _RxStreamBuilderState<T> createState() => _RxStreamBuilderState();

  /// Get latest value from stream or throw an [ArgumentError].
  @visibleForTesting
  static T getInitialData<T>(ValueStream<T> stream) {
    if (stream is StateStream<T>) {
      return stream.value;
    }
    if (stream.hasValue) {
      return stream.value;
    }
    throw ArgumentError.value(stream, 'stream', 'has no value');
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
    final stream = widget._stream;
    value = RxStreamBuilder.getInitialData(stream);

    subscription = stream.listen(
      (v) {
        if (RxStreamBuilder.checkStateStreamEnabled &&
            stream is StateStream<T> &&
            stream.equals(value, v)) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: InvalidStateStreamError(stream, value),
              stack: StackTrace.current,
              library: 'flutter_bloc_pattern',
            ),
          );
        }

        setState(() => value = v);
      },
      onError: (Object e, StackTrace s) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: UnhandledStreamError(e),
            stack: s,
            library: 'flutter_bloc_pattern',
          ),
        );
      },
    );
  }

  void unsubscribe() {
    subscription?.cancel();
    subscription = null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty.lazy('value', () => value));
    properties.add(DiagnosticsProperty('subscription', subscription));
    properties.add(DiagnosticsProperty('stream', widget._stream));
  }
}
