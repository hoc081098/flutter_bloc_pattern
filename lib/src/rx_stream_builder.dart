import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

// ignore_for_file: unnecessary_null_comparison

/// Signature for strategies that build widgets based on asynchronous interaction.
typedef RxWidgetBuilder<T> = Widget Function(BuildContext context, T? data);

/// Rx stream builder that will pre-populate the streams initial data if the
/// given stream is an stream that holds the streams current value such
/// as a [ValueStream] or a [ReplayStream]
class RxStreamBuilder<T> extends StatelessWidget {
  final AsyncWidgetBuilder<T> _builder;

  /// The asynchronous computation to which this builder is currently connected,
  /// possibly null. When changed, the current summary is updated using
  /// [afterDisconnected], if the previous stream was not null, followed by
  /// [afterConnected], if the new stream is not null.
  final Stream<T> stream;

  /// The data that will be used to create the initial snapshot.
  ///
  /// Providing this value (presumably obtained synchronously somehow when the
  /// [Stream] was created) ensures that the first frame will show useful data.
  /// Otherwise, the first frame will be built with the value null, regardless
  /// of whether a value is available on the stream: since streams are
  /// asynchronous, no events from the stream can be obtained before the initial
  /// build.
  final T? initialData;

  /// Creates a new [RxStreamBuilder] that builds itself based on the latest
  /// snapshot of interaction with the specified [stream] and whose build
  /// strategy is given by [builder].
  ///
  /// The [initialData] is used to create the initial snapshot.
  ///
  /// The [builder] must not be null. It must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  RxStreamBuilder({
    Key? key,
    required RxWidgetBuilder<T> builder,
    required this.stream,
    this.initialData,
  })  : assert(builder != null),
        assert(stream != null),
        _builder = _createStreamBuilder<T>(builder),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      initialData: getInitialData(initialData, stream),
      builder: _builder,
      stream: stream,
    );
  }

  @visibleForTesting
  static T? getInitialData<T>(T? initialData, Stream<T> stream) {
    if (initialData != null) {
      return initialData;
    }

    if (stream is ValueStream<T> && stream.hasValue) {
      return stream.requireValue;
    }

    if (stream is ReplayStream<T>) {
      final values = stream.values;
      if (values.isNotEmpty) {
        return values.last;
      }
    }

    return null;
  }

  static AsyncWidgetBuilder<T> _createStreamBuilder<T>(
          RxWidgetBuilder<T> builder) =>
      (context, snapshot) => builder(context, snapshot.data);
}
