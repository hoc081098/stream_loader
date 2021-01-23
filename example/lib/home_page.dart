import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:stream_loader/stream_loader.dart';

import 'data/api.dart';
import 'data/comment.dart';
import 'detail_page.dart';

// ignore_for_file: deprecated_member_use

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
              messageHandler: handleMessage,
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
                final items = state.content;

                return RefreshIndicator(
                  child: ListView.separated(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final comment = items[index];

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

  void handleMessage(
    BuildContext context,
    LoaderMessage<BuiltList<Comment>> message,
    LoaderBloc<BuiltList<Comment>> bloc,
  ) {
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
