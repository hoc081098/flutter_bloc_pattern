/// Base class for all bloc
abstract class BaseBloc {
  /// close stream controllers, cancel subscriptions
  void dispose();
}

class DisposeCallbackBaseBloc implements BaseBloc {
  final void Function() _dispose;

  DisposeCallbackBaseBloc(this._dispose) {
    ArgumentError.checkNotNull(_dispose, '_dispose');
  }

  @override
  void dispose() => _dispose();
}
