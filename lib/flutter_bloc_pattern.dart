library flutter_bloc_pattern;

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// Base class for all bloc
abstract class BaseBloc {
  /// close stream controllers, cancel subscriptions
  void dispose();
}

class DisposeCallbackBaseBloc implements BaseBloc {
  final void Function() _dispose;

  const DisposeCallbackBaseBloc(this._dispose) : assert(_dispose != null);

  @override
  void dispose() => _dispose();
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
    this.child,
  }) : super(key: key);

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

  BlocProvider<T> copyWithChild(Widget child) {
    return BlocProvider<T>(
      initBloc: initBloc,
      child: child,
      key: key,
    );
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

/// A bloc provider that exposes that merges multiple other [BlocProvider]s into one.
///
/// [BlocProviders] is used to improve the readability and reduce the boilerplate of
/// having many nested providers.
///
/// As such, we're going from:
///
/// ```dart
/// BlocProvider<BlocA>(
///   initBloc: () => blocA,
///   child: BlocProvider<BlocB>(
///     initBloc: () => blocB,
///     child: BlocProvider<BlocC>(
///       initBloc: () => blocC,
///       child: someWidget,
///     )
///   )
/// )
/// ```
///
/// To:
///
/// ```dart
/// BlocProviders(
///   blocProviders: [
///     BlocProvider<BlocA>(initBloc: () => blocA),
///     BlocProvider<BlocB>(initBloc: () => blocB),
///     BlocProvider<BlocC>(initBloc: () => blocC),
///   ],
///   child: someWidget,
/// )
/// ```
///
/// Technically, these two are identical. [BlocProviders] will convert the list into a tree.
/// This changes only the appearance of the code.
class BlocProviders extends StatelessWidget {
  /// The list of bloc providers that will be transformed into a tree.
  /// The tree is created from top to bottom.
  /// The first item because to topmost provider, while the last item it the direct parent of [child].
  final List<BlocProvider<dynamic>> blocProviders;

  /// The child of the last provider in [blocProviders].
  /// If [blocProviders] is empty, then [BlocProviders] just returns [child].
  final Widget child;

  const BlocProviders({
    Key key,
    @required this.blocProviders,
    @required this.child,
  })  : assert(blocProviders != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) =>
      blocProviders.reversed.fold(child, (acc, e) => e.copyWithChild(acc));
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
