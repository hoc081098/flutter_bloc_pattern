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
    return StreamBuilder<int>(
      stream: bloc.state,
      initialData: bloc.state.value,
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
