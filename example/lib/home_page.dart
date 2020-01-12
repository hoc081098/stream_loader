import 'package:example/data/api.dart';
import 'package:example/data/comment.dart';
import 'package:example/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:stream_loader/stream_loader.dart';
import 'package:built_collection/built_collection.dart';

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
        child: Consumer<Api>(
          builder: (context, api) {
            return LoaderWidget<BuiltList<Comment>>(
              blocProvider: () => LoaderBloc(
                loaderFunction: api.getComments,
                initial: BuiltList.of([]),
                enableLogger: false,
              ),
              messageHandler: (message, _) => handleMessage(message, context),
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
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return RefreshIndicator(
                  child: ListView.separated(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: state.content.length,
                    itemBuilder: (context, index) {
                      var comment = state.content[index];
                      return ListTile(
                        title: Text(comment.name),
                        subtitle: Text(comment.email),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(comment: comment),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
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

  void handleMessage(LoaderMessage message, BuildContext context) {
    message.fold(
      onFetchFailure: (error, stackTrace) => context.snackBar('Fetch error'),
      onFetchSuccess: (_) {},
      onRefreshSuccess: (data) => context.snackBar('Refresh success'),
      onRefreshFailure: (error, stackTrace) =>
          context.snackBar('Refresh error'),
    );
  }
}

extension SnackBarExt on BuildContext {
  void snackBar(String message) {
    Scaffold.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
