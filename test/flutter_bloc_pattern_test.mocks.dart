import 'package:mockito/mockito.dart' as _i1;
import 'package:flutter_bloc_pattern/src/base.dart' as _i2;
import 'flutter_bloc_pattern_test.dart' as _i3;
import 'package:flutter/src/widgets/framework.dart' as _i4;

class _FakeBaseBloc extends _i1.Fake implements _i2.BaseBloc {}

/// A class which mocks [BaseBlocProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockBaseBlocProvider extends _i1.Mock implements _i3.BaseBlocProvider {
  MockBaseBlocProvider() {
    _i1.throwOnMissingStub(this);
  }

  _i2.BaseBloc call(_i4.BuildContext? context) =>
      (super.noSuchMethod(Invocation.method(#call, [context]), _FakeBaseBloc())
          as _i2.BaseBloc);
}

/// A class which mocks [BaseBloc].
///
/// See the documentation for Mockito's code generation for more information.
class MockBloc extends _i1.Mock implements _i2.BaseBloc {
  MockBloc() {
    _i1.throwOnMissingStub(this);
  }
}

/// A class which mocks [BaseBloc].
///
/// See the documentation for Mockito's code generation for more information.
class BlocA extends _i1.Mock implements _i2.BaseBloc {
  BlocA() {
    _i1.throwOnMissingStub(this);
  }
}

/// A class which mocks [BaseBloc].
///
/// See the documentation for Mockito's code generation for more information.
class BlocB extends _i1.Mock implements _i2.BaseBloc {
  BlocB() {
    _i1.throwOnMissingStub(this);
  }
}

/// A class which mocks [DisposeCallbackBaseBloc].
///
/// See the documentation for Mockito's code generation for more information.
class BlocC extends _i1.Mock implements _i2.DisposeCallbackBaseBloc {
  BlocC() {
    _i1.throwOnMissingStub(this);
  }
}
