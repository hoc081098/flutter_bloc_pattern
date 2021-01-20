/// Base class for all bloc
abstract class BaseBloc {
  /// close stream controllers, cancel subscriptions
  void dispose();
}

class DisposeCallbackBaseBloc implements BaseBloc {
  final void Function() _dispose;

  // ignore: unnecessary_null_comparison
  DisposeCallbackBaseBloc(this._dispose) : assert(_dispose != null);

  @override
  void dispose() => _dispose();
}
