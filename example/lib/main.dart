import 'package:flutter/material.dart';
import 'package:stream_loader/stream_loader.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo stream_loader'),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Builder(
          builder: (context) {
            return LoaderWidget<List<int>>(
              blocProvider: () => LoaderBloc(
                loaderFunction: loader,
                refresherFunction: refresher,
              ),
              handleMessage: (message, bloc) {
                final msg = message.fold(
                  onFetchFailure: (error, stackTrace) {
                    context.snackBar('Fetch error');
                    return 'Fetch error $error, $stackTrace';
                  },
                  onFetchSuccess: (data) => 'Fetch success $data',
                  onRefreshSuccess: (data) {
                    context.snackBar('Refresh success');
                    return 'Refresh success $data';
                  },
                  onRefreshFailure: (error, stackTrace) {
                    context.snackBar('Refresh error');
                    return 'Refresh error $error, $stackTrace';
                  },
                );
                print(msg);
              },
              builder: (context, state, bloc) {
                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Error: ${state.error}'),
                        const SizedBox(height: 8),
                        RaisedButton(
                          onPressed: bloc.fetch,
                          child: Text('Retry'),
                        )
                      ],
                    ),
                  );
                }
                if (state.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: state.content.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text('Item ${state.content[index]}'),
                    ),
                  ),
                  onRefresh: bloc.refresh,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<List<int>> refresher() async* {
    await Future.delayed(const Duration(seconds: 2));
    yield List.generate(20, (i) => 20 - i);
  }

  Stream<List<int>> loader() async* {
    await Future.delayed(const Duration(seconds: 2));
    yield List.generate(10, (i) => i);
    await Future.delayed(const Duration(seconds: 2));
    yield List.generate(30, (i) => i);
  }
}

extension on BuildContext {
  void snackBar(String message) {
    Scaffold.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
