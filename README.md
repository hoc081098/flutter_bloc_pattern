# flutter_bloc_pattern

Base class, BLoC provider and `rxdart` builder for BLoC pattern in Flutter.

[![Flutter test](https://github.com/hoc081098/flutter_bloc_pattern/workflows/Flutter%20test/badge.svg)](https://github.com/hoc081098/flutter_bloc_pattern/actions)
[![Pub](https://img.shields.io/pub/v/flutter_bloc_pattern.svg)](https://pub.dev/packages/flutter_bloc_pattern)
[![Pub](https://img.shields.io/pub/v/flutter_bloc_pattern?include_prereleases)](https://pub.dev/packages/flutter_bloc_pattern)
[![codecov](https://codecov.io/gh/hoc081098/flutter_bloc_pattern/branch/master/graph/badge.svg?token=yhrC5lmOqu)](https://codecov.io/gh/hoc081098/flutter_bloc_pattern)
[![GitHub](https://img.shields.io/github/license/hoc081098/flutter_bloc_pattern?color=4EB1BA)](https://opensource.org/licenses/MIT)
[![Style](https://img.shields.io/badge/style-pedantic-40c4ff.svg)](https://github.com/dart-lang/pedantic)

## Getting Started

### 1. Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  flutter_bloc_pattern: <latest_version>
```

### 2. Now in your Dart code, you can use:

```dart
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
```

### 3. Implements BaseBloc:
```dart
class MyBloc implements BaseBloc {
  Stream<String> get stream;

  @override
  void dispose() {}
}
```

### 4. Consume BLoC:
```dart
 final bloc = BlocProvider.of<MyBloc>(context);
 return RxStreamBuilder(
  stream: bloc.stream,
  builder: (context, data) {
    return ...;
  },
);
```

## Example: A port of the standard "Counter Button" example from Flutter

### 1. File `counter_bloc.dart`:
```dart
import 'dart:async';

import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class CounterBloc extends DisposeCallbackBaseBloc {
  /// Inputs
  final VoidAction increment;

  /// Outputs
  final StateStream<int> state;

  CounterBloc._({
    required void Function() dispose,
    required this.increment,
    required this.state,
  }) : super(dispose);

  factory CounterBloc() {
    // ignore: close_sinks
    final incrementController = StreamController<void>();

    final state = incrementController.stream
        .scan<int>((acc, _, __) => acc + 1, 0)
        .publishState(0);
    final connection = state.connect();

    return CounterBloc._(
      dispose: () async {
        await connection.cancel();
        await incrementController.close();
        print('CounterBloc::disposed');
      },
      increment: () => incrementController.add(null),
      state: state,
    );
  }
}
```

### 2. File `main.dart`:
```dart
import 'package:example/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';

class TextCounter1 extends StatelessWidget {
  const TextCounter1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CounterBloc>(context);

    return RxStreamBuilder<int>(
      stream: bloc.state,
      builder: (context, state) {
        return Text(
          'COUNTER 1: $state',
          style: Theme.of(context).textTheme.headline6,
        );
      },
    );
  }
}

class IncrementButton extends StatelessWidget {
  const IncrementButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.bloc<CounterBloc>();

    return FloatingActionButton(
      onPressed: bloc.increment,
      tooltip: 'Increment',
      child: Icon(Icons.add),
    );
  }
}

```
