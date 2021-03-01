/// Base class for all bloc
abstract class BaseBloc {
  /// close stream controllers, cancel subscriptions
  void dispose();
}

/// Base bloc that implements [BaseBloc.dispose] by passing callback to constructor,
/// and call it when [BaseBloc.dispose] called.
class DisposeCallbackBaseBloc implements BaseBloc {
  final void Function() _dispose;

  /// Create a [DisposeCallbackBaseBloc] by a dispose callback.
  // ignore: unnecessary_null_comparison
  DisposeCallbackBaseBloc(this._dispose) : assert(_dispose != null);

  @override
  void dispose() => _dispose();
}

// Function types

/// Represents a function that have no arguments and return no data.
typedef VoidAction = void Function();

/// Represents a function with zero arguments: `() -> R`.
typedef Func0<R> = R Function();

/// Represents a function with one argument: `(T) -> R`.
typedef Func1<T, R> = R Function(T);

/// Represents a function with two arguments: `(T1, T2) -> R`.
typedef Func2<T1, T2, R> = R Function(T1, T2);

/// Represents a function with three arguments: `(T1, T2, T3) -> R`.
typedef Func3<T1, T2, T3, R> = R Function(T1, T2, T3);

/// Represents a function with four arguments: `(T1, T2, T3, T4) -> R`.
typedef Func4<T1, T2, T3, T4, R> = R Function(T1, T2, T3, T4);

/// Represents a function with five arguments: `(T1, T2, T3, T4, T5) -> R`.
typedef Func5<T1, T2, T3, T4, T5, R> = R Function(T1, T2, T3, T4, T5);

/// Represents a function with six arguments: `(T1, T2, T3, T4, T5, T6) -> R`.
typedef Func6<T1, T2, T3, T4, T5, T6, R> = R Function(T1, T2, T3, T4, T5, T6);

/// Represents a function with seven arguments: `(T1, T2, T3, T4, T5, T6, T7) -> R`.
typedef Func7<T1, T2, T3, T4, T5, T6, T7, R> = R Function(
  T1,
  T2,
  T3,
  T4,
  T5,
  T6,
  T7,
);

/// Represents a function with eight arguments: `(T1, T2, T3, T4, T5, T6, T7, T8) -> R`.
typedef Func8<T1, T2, T3, T4, T5, T6, T7, T8, R> = R Function(
  T1,
  T2,
  T3,
  T4,
  T5,
  T6,
  T7,
  T8,
);

/// Represents a function with nine arguments: `(T1, T2, T3, T4, T5, T6, T7, T8, T9) -> R`.
typedef Func9<T1, T2, T3, T4, T5, T6, T7, T8, T9, R> = R Function(
  T1,
  T2,
  T3,
  T4,
  T5,
  T6,
  T7,
  T8,
  T9,
);
