import 'rx_stream_builder.dart';

/// If the BlocProvider.of method fails, this error will be thrown.
///
/// Often, when the `of` method fails, it is difficult to understand why since
/// there can be multiple causes. This error explains those causes so the user
/// can understand and fix the issue.
class BlocProviderError extends Error {
  /// The type of the class the user tried to retrieve
  final Type? type;

  /// Creates a BlocProviderError
  BlocProviderError(this.type);

  @override
  String toString() {
    if (type == null) {
      return '''Error: please specify type instead of using dynamic when calling BlocProvider.of<T>() or context.bloc<T>() method.''';
    }

    return '''Error: No $type found. To fix, please try:
  * Wrapping your MaterialApp with the BlocProvider<$type>, 
  rather than an individual Route.
  * Providing full type information to BlocProvider<$type>, BlocProvider.of<$type> and context.bloc<$type>() method
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_bloc_pattern/issues/new
      ''';
  }
}

/// Error emitted from [Stream] when using [RxStreamBuilder].
class UnhandledStreamError extends Error {
  /// Error emitted from [Stream].
  final Object error;

  @override
  final StackTrace stackTrace;

  /// Create a [UnhandledStreamError] from [error].
  UnhandledStreamError(this.error, this.stackTrace);

  @override
  String toString() {
    return '''Unhandled error from Stream: $error.
You should use one of following methods to handle error before passing stream to RxStreamBuilder:
  * stream.handleError((e, s) { })
  * stream.onErrorReturn(value)
  * stream.onErrorReturnWith((e) => value)
  * stream.onErrorResumeNext(otherStream)
  * stream.onErrorResume((e) => otherStream)
  * stream.transform(
        StreamTransformer.fromHandlers(handleError: (e, s, sink) {}))
  ...
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_bloc_pattern/issues/new
''';
  }
}
