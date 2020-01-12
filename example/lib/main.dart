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
        child: LoaderWidget<List<int>>(
          blocProvider: () => LoaderBloc(
            loaderFunction: () async* {
              await Future.delayed(const Duration(seconds: 2));
              yield List.generate(20, (i) => i);
              await Future.delayed(const Duration(seconds: 2));
              yield List.generate(30, (i) => i);
            },
            refresherFunction: () async* {
              yield List.generate(20, (i) => 20 - i);
            },
          ),
          handleMessage: (message, bloc) {
            message.fold(
              onFetchFailure: (error, stackTrace) =>
                  print('Fetch error $error, $stackTrace'),
              onFetchSuccess: (data) => print('Fetch success $data'),
              onRefreshSuccess: (data) => print('Refresh success $data'),
              onRefreshFailure: (error, stackTrace) =>
                  print('Refresh error $error, $stackTrace'),
            );
          },
          builder: (context, state, bloc) {
            if (state.error != null) {
              return Center(
                child: Column(
                  children: <Widget>[
                    Text('Error ${state.error}'),
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
        ),
      ),
    );
  }
}
