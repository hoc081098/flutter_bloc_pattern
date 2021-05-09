import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'error.dart';

// ignore_for_file: unnecessary_null_comparison

/// Signature for strategies that build widgets based on asynchronous interaction.
typedef RxWidgetBuilder<T extends Object> = Widget Function(
    BuildContext context, T data);

/// Rx stream builder that will pre-populate the streams initial data if the
/// given stream is an stream that holds the streams current value such
/// as a [ValueStream] or a [ReplayStream]
class RxStreamBuilder<T extends Object> extends StreamBuilder<T> {
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
    required Stream<T> stream,
    T? initialData,
  })  : assert(builder != null),
        assert(stream != null),
        super(
          key: key,
          initialData: getInitialData(initialData, stream),
          builder: _createStreamBuilder<T>(builder),
          stream: stream,
        );

  /// Get latest value from stream or return `null`.
  @visibleForTesting
  static T getInitialData<T>(T? initialData, Stream<T> stream) {
    if (initialData != null) {
      return initialData;
    }

    if (stream is ValueStream<T> && stream.hasValue) {
      return stream.value;
    }

    if (stream is ReplayStream<T>) {
      final values = stream.values;
      if (values.isNotEmpty) {
        return values.last;
      }
    }

    throw StateError('Should provide initialData!');
  }

  static AsyncWidgetBuilder<T> _createStreamBuilder<T extends Object>(
          RxWidgetBuilder<T> builder) =>
      (context, snapshot) {
        if (snapshot.hasError) {
          throw UnhandledStreamError(snapshot.error!);
        }
        return builder(context, snapshot.requireData);
      };
}
