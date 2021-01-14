import 'package:flutter/widgets.dart';
import 'package:flutter_provider/flutter_provider.dart';

import 'base.dart';
import 'error.dart';

/// Provides [BaseBloc] to all descendants of this Widget. This should
/// generally be a root widget in your App
class BlocProvider<T extends BaseBloc> extends Provider<T> {
  final T Function(BuildContext) initBloc;
  final Widget? child;

  BlocProvider({
    Key? key,
    required this.initBloc,
    this.child,
  })  : assert(initBloc != null),
        super.factory(
          key: key,
          factory: initBloc,
          disposer: (bloc) => bloc.dispose(),
          child: child,
        );

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
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderError catch (e) {
      throw BlocProviderError(e.type);
    }
  }
}

/// Retrieve the bloc from the [BlocProvider] by this [BuildContext].
extension BlocProviderExtension on BuildContext {
  /// Retrieve the bloc from the [BlocProvider] by this [BuildContext].
  T bloc<T extends BaseBloc>({bool listen = false}) =>
      BlocProvider.of<T>(this, listen: listen);
}
