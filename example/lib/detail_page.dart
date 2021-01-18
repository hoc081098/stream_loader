import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:stream_loader/stream_loader.dart';

import 'data/api.dart';
import 'data/comment.dart';
import 'home_page.dart' show SnackBarExt;

class DetailPage extends StatelessWidget {
  final Comment comment;

  const DetailPage({Key key, @required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment detail'),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Consumer<Api>(
          builder: (context, api) {
            final loadDetail = () => api.getCommentBy(id: comment.id);

            return LoaderWidget<Comment>(
              blocProvider: () {
                return LoaderBloc(
                  loaderFunction: loadDetail,
                  refresherFunction: loadDetail,
                  initialContent: comment,
                  logger: print,
                );
              },
              messageHandler: (message, _) {
                message.fold(
                  onFetchFailure: (_, __) => null,
                  onFetchSuccess: (_) => null,
                  onRefreshFailure: (_, __) => null,
                  onRefreshSuccess: (_) => context.snackBar('Refresh success'),
                );
              },
              builder: (context, state, bloc) {
                final comment = state.content;

                return RefreshIndicator(
                  onRefresh: bloc.refresh,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.label),
                            title: Text('Post id'),
                            subtitle: Text(comment.postId.toString()),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(Icons.add),
                            title: Text('Id'),
                            subtitle: Text(comment.id.toString()),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text('Name'),
                            subtitle: Text(comment.name),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(Icons.email),
                            title: Text('Email'),
                            subtitle: Text(comment.email),
                          ),
                          const Divider(),
                          ExpansionTile(
                            leading: Icon(Icons.message),
                            title: Text('Body'),
                            children: <Widget>[
                              Text(comment.body),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
