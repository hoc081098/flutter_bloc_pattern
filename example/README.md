[Simple example](https://github.com/hoc081098/flutter_bloc_pattern/tree/master/example/counter) a port of the standard "Counter Button" example from Flutter.

### 1. File `counter_bloc.dart`:
```dart
import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class CounterBloc extends DisposeCallbackBaseBloc {
  /// Inputs
  final VoidAction increment;

  /// Outputs
  final StateStream<int> state;

  CounterBloc._({
    required VoidAction dispose,
    required this.increment,
    required this.state,
  }) : super(dispose);

  factory CounterBloc() {
    final incrementController = StreamController<void>();

    final state$ = incrementController.stream
        .scan<int>((acc, _, __) => acc + 1, 0)
        .publishState(0);

    return CounterBloc._(
      dispose: DisposeBag([incrementController, state$.connect()]).dispose,
      increment: incrementController.addNull,
      state: state$,
    );
  }
}
```

### 2. File `main.dart`:
```dart
import 'package:example/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter bloc pattern',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return BlocProvider<CounterBloc>(
                  child: MyHomePage(),
                  initBloc: () => CounterBloc(),
                );
              },
            ),
          ),
          child: Text('GO TO HOME'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
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
            TextCounter1(),
            TextCounter2(),
          ],
        ),
      ),
      floatingActionButton: const IncrementButton(),
    );
  }
}

class TextCounter1 extends StatelessWidget {
  const TextCounter1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CounterBloc>(context);

    return RxStreamBuilder<int>(
      stream: bloc.state,
      builder: (context, data) {
        return Text(
          'COUNTER 1: $data',
          style: Theme.of(context).textTheme.headline4,
        );
      },
    );
  }
}

class TextCounter2 extends StatelessWidget {
  const TextCounter2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.bloc<CounterBloc>();

    return RxStreamBuilder<int>(
      stream: bloc.state,
      builder: (context, data) {
        return Text(
          'COUNTER 2: $data',
          style: Theme.of(context).textTheme.headline4,
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
