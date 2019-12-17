library flutter_bloc_pattern;

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// Base class for all bloc
abstract class BaseBloc {
  /// close stream controllers, cancel subscriptions
  void dispose();
}

// Workaround to capture generics
Type _typeOf<T>() => T;

/// Provides [BaseBloc] to all descendants of this Widget. This should
/// generally be a root widget in your App
class BlocProvider<T extends BaseBloc> extends StatefulWidget {
  final ValueGetter<T> initBloc;
  final Widget child;

  const BlocProvider({
    Key key,
    @required this.initBloc,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  /// A method that can be called by descendant Widgets to retrieve the bloc
  /// from the [BlocProvider].
  ///
  /// Important: When using this method, pass through complete type information
  /// or Flutter will be unable to find the correct [_BlocProviderInherited]!
  ///
  /// ### Example
  ///
  /// ```
  /// class MyWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final bloc = BlocProvider.of<CounterBloc>(context);
  ///
  ///     return StreamBuilder<int>(
  ///       stream: bloc.counter,
  ///       builder: (context, snapshot) {
  ///         return Text(snapshot.data.toString());
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  static T of<T extends BaseBloc>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_BlocProviderInherited<T>>();
    if (provider == null) {
      throw BlocProviderError(_typeOf<_BlocProviderInherited<T>>());
    }
    return provider.bloc;
  }
}

class _BlocProviderState<T extends BaseBloc> extends State<BlocProvider<T>> {
  T _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.initBloc();
  }

  @override
  Widget build(BuildContext context) {
    return _BlocProviderInherited<T>(
      child: widget.child,
      bloc: _bloc,
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class _BlocProviderInherited<T extends BaseBloc> extends InheritedWidget {
  final T bloc;

  const _BlocProviderInherited({
    Key key,
    @required Widget child,
    @required this.bloc,
  })  : assert(child != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_BlocProviderInherited<T> old) => bloc != old.bloc;
}

/// If the BlocProvider.of method fails, this error will be thrown.
///
/// Often, when the `of` method fails, it is difficult to understand why since
/// there can be multiple causes. This error explains those causes so the user
/// can understand and fix the issue.
class BlocProviderError extends Error {
  /// The type of the class the user tried to retrieve
  Type type;

  /// Creates a BlocProviderError
  BlocProviderError(this.type);

  @override
  String toString() {
    return '''Error: No $type found. To fix, please try:
  * Wrapping your MaterialApp with the BlocProvider<T>, 
  rather than an individual Route
  * Providing full type information to BlocProvider<T> and BlocProvider.of<T> method
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_bloc_pattern/issues/new
      ''';
  }
}

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
  final T initialData;

  RxStreamBuilder({
    Key key,
    @required this.builder,
    @required this.stream,
    this.initialData,
  })  : assert(builder != null),
        assert(stream != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      initialData: getInitialData(initialData, stream),
      builder: builder,
      stream: stream,
    );
  }

  @visibleForTesting
  static T getInitialData<T>(T initialData, Stream<T> stream) {
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
    return null;
  }
}
