import 'package:flutter/widgets.dart';
import 'package:flutter_provider/flutter_provider.dart';

import 'base.dart';
import 'error.dart';

/// Provides [BaseBloc] to all descendants of this Widget. This should
/// generally be a root widget in your App
class BlocProvider<T extends BaseBloc> extends StatelessWidget {
  final Provider<T> _provider;

  /// Create a [BlocProvider] that provides a bloc to all descendants.
  /// The bloc created on first access, by calling [initBloc].
  ///
  /// [BaseBloc.dispose] will be called when [BlocProvider] is removed from the tree permanently
  /// ([State.dispose] called).
  BlocProvider({
    super.key,
    required T Function(BuildContext) initBloc,
    Widget? child,
  }) : _provider = Provider<T>.factory(
          initBloc,
          key: key,
          disposer: (bloc) => bloc.dispose(),
          child: child,
        );

  /// A method that can be called by descendant Widgets to retrieve the bloc
  /// from the [BlocProvider].
  ///
  /// Important: When using this method, pass through complete type information
  /// or Flutter will be unable to find the correct bloc!
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

  @override
  Widget build(BuildContext context) => _provider;
}

/// Retrieve the bloc from the [BlocProvider] by this [BuildContext].
extension BlocProviderExtension on BuildContext {
  /// Retrieve the bloc from the [BlocProvider] by this [BuildContext].
  T bloc<T extends BaseBloc>({bool listen = false}) =>
      BlocProvider.of<T>(this, listen: listen);
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
class BlocProviders extends Providers {
  /// The [blocProviders] is a list of bloc providers that will be transformed into a tree.
  /// The tree is created from top to bottom.
  /// The first item because to topmost provider, while the last item it the direct parent of [child].
  ///
  /// The [child] is child of the last provider in [blocProviders].
  ///
  /// If [blocProviders] is empty, then [BlocProviders] just returns [child].
  BlocProviders({
    super.key,
    required List<BlocProvider> blocProviders,
    required super.child,
  })  : assert(blocProviders.isNotEmpty),
        super(
          providers:
              blocProviders.map((e) => e._provider).toList(growable: false),
        );
}
