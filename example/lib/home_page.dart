import 'package:built_collection/built_collection.dart';
import 'package:example/data/api.dart';
import 'package:example/data/comment.dart';
import 'package:example/detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:stream_loader/stream_loader.dart';

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
                refresherFunction: api.getComments,
                initialContent: BuiltList.of([]),
              ),
              messageHandler: (message, _) => handleMessage(message, context),
              builder: (context, state, bloc) {
                if (state.error != null) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Error: ${state.error}',
                          textAlign: TextAlign.center,
                        ),
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
                var items = state.content;

                return RefreshIndicator(
                  child: ListView.separated(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var comment = items[index];

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(comment.name[0]),
                          backgroundColor:
                              Colors.primaries[index % Colors.primaries.length],
                          maxRadius: 32,
                          minRadius: 32,
                        ),
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
    // ignore: deprecated_member_use
    Scaffold.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
