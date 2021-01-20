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
