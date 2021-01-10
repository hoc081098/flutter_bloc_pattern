import 'package:flutter/widgets.dart';

import 'base.dart';
import 'error.dart';

// Workaround to capture generics
Type _typeOf<T>() => T;

/// Provides [BaseBloc] to all descendants of this Widget. This should
/// generally be a root widget in your App
class BlocProvider<T extends BaseBloc> extends StatefulWidget {
  final ValueGetter<T> initBloc;
  final Widget? child;

  const BlocProvider({
    Key? key,
    required this.initBloc,
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
  static T of<T extends BaseBloc>(BuildContext context, {bool listen = false}) {
    if (T == dynamic) {
      throw BlocProviderError(null);
    }

    final provider = listen
        ? context
            .dependOnInheritedWidgetOfExactType<_BlocProviderInherited<T>>()
        : (context
            .getElementForInheritedWidgetOfExactType<
                _BlocProviderInherited<T>>()
            ?.widget as _BlocProviderInherited<T>?);

    if (provider == null) {
      throw BlocProviderError(T);
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

extension BlocProviderExtension on BuildContext {
  T bloc<T extends BaseBloc>({bool listen = false}) =>
      BlocProvider.of<T>(this, listen: listen);
}

class _BlocProviderState<T extends BaseBloc> extends State<BlocProvider<T>> {
  late T _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.initBloc();
  }

  @override
  Widget build(BuildContext context) {
    return _BlocProviderInherited<T>(
      child: widget.child!,
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

  _BlocProviderInherited({
    Key? key,
    required Widget child,
    required this.bloc,
  }) : super(key: key, child: child) {
    ArgumentError.checkNotNull(child, 'child');
  }

  @override
  bool updateShouldNotify(_BlocProviderInherited<T> old) => bloc != old.bloc;
}
