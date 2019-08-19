# flutter_bloc_pattern

Base class, provider and rxdart builder for BLoC pattern in flutter

## Getting Started

### 1. Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  flutter_bloc_pattern: ^1.0.0
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
  builder: (context, snapshot) {
    final String data = snapshot.data;
    return ...;
  },
);
```

## Example: A port of the standard "Counter Button" example from Flutter <br>

### 1. File `counter_bloc.dart`:
```dart
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

//ignore_for_file: close_sinks
class CounterBloc implements BaseBloc {
  /// Inputs
  final void Function() increment;

  /// Outputs
  final ValueObservable<int> state;

  /// Clean up
  final void Function() _dispose;

  CounterBloc._(
    this._dispose, {
    @required this.increment,
    @required this.state,
  });

  factory CounterBloc() {
    final incrementController = PublishSubject<void>();
    final state = incrementController
        .scan<int>((acc, _, __) => acc + 1, 0)
        .shareValue(seedValue: 0);

    return CounterBloc._(
      incrementController.close,
      increment: () => incrementController.add(null),
      state: state,
    );
  }

  @override
  void dispose() => _dispose();
}
```

### 2. File `main.dart`:
```dart
import 'package:counter/counter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';

void main() {
  runApp(
    BlocProvider<CounterBloc>(
      child: MyApp(),
      initBloc: () => CounterBloc(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text('You have pushed the button this many times:'),
            TextCounter(),
          ],
        ),
      ),
      floatingActionButton:
          const IncrementButton(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TextCounter extends StatelessWidget {
  const TextCounter({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CounterBloc>(context);
    return RxStreamBuilder<int>(
      stream: bloc.state,
      builder: (context, snapshot) {
        return Text(
          '${snapshot.data}',
          style: Theme.of(context).textTheme.display1,
        );
      },
    );
  }
}

class IncrementButton extends StatelessWidget {
  const IncrementButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CounterBloc>(context);
    return FloatingActionButton(
      onPressed: bloc.increment,
      tooltip: 'Increment',
      child: Icon(Icons.add),
    );
  }
}
```
