import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

/// Rx stream builder that will pre-populate the streams initial data if the
/// given stream is an stream that holds the streams current value such
/// as a [ValueStream] or a [ReplayStream]
class RxStreamBuilder<T> extends StatelessWidget {
  /// The build strategy currently used by this builder.
  final AsyncWidgetBuilder<T> builder;

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

  RxStreamBuilder({
    Key? key,
    required this.builder,
    required this.stream,
    this.initialData,
  }) : super(key: key) {
    ArgumentError.checkNotNull(builder, 'builder');
    ArgumentError.checkNotNull(stream, 'stream');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      initialData: getInitialData(initialData, stream),
      builder: builder,
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
}
