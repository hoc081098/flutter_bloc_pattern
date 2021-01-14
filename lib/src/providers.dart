import 'package:flutter/widgets.dart';
import 'package:flutter_provider/flutter_provider.dart';

import 'provider.dart';

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
    Key? key,
    required List<BlocProvider> blocProviders,
    required Widget child,
  })   : assert(blocProviders != null),
        assert(child != null),
        super(
          key: key,
          providers: blocProviders,
          child: child,
        );
}
