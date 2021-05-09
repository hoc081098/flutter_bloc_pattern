import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

import 'bloc_with_deps.dart';
import 'counter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<Dependencies>.factory(
      (_) => Dependencies(),
      disposer: (d) => d.dispose(),
      child: MaterialApp(
        title: 'Flutter bloc pattern',
        theme: ThemeData.dark(),
        home: StartPage(),
      ),
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
                  initBloc: (_) => CounterBloc(),
                  child: BlocProviders(
                    blocProviders: [
                      BlocProvider<Bloc1>(
                        initBloc: (context) => Bloc1(context.get()),
                      ),
                      BlocProvider<Bloc2>(
                        initBloc: (context) => Bloc2(context.bloc()),
                      ),
                    ],
                    child: MyHomePage(),
                  ),
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
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            const SizedBox(height: 8),
            TextCounter1(),
            TextCounter2(),
            const SizedBox(height: 8),
            TextBloc1(),
            ElevatedButton(
              onPressed: () => context.bloc<Bloc2>(),
              child: Text('Access Bloc 2'),
            )
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
      builder: (context, state) {
        return Text(
          'COUNTER 1: $state',
          style: Theme.of(context).textTheme.headline6,
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
      builder: (context, state) {
        return Text(
          'COUNTER 2: $state',
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

class TextBloc1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.bloc<Bloc1>();

    return RxStreamBuilder<ValueWrapper<String?>>(
      stream: bloc.string$,
      builder: (context, state) {
        return ElevatedButton(
          child: Text(
            'BLOC 1: ${state.value ?? 'No data'}. Click to load',
          ),
          onPressed: bloc.load,
        );
      },
    );
  }
}
