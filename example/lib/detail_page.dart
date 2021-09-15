import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:stream_loader/stream_loader.dart';

import 'data/api.dart';
import 'data/comment.dart';
import 'home_page.dart' show SnackBarExt;

class DetailPage extends StatelessWidget {
  final Comment comment;

  const DetailPage({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment detail'),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: Consumer<Api>(
          builder: (context, api) {
            Stream<Comment> loadDetail() => api.getCommentBy(id: comment.id);

            return LoaderWidget<Comment>(
              blocProvider: () {
                return LoaderBloc(
                  loaderFunction: loadDetail,
                  refresherFunction: loadDetail,
                  initialContent: comment,
                  logger: debugPrint,
                );
              },
              messageHandler: (context, message, _) {
                message.fold(
                  onFetchFailure: (_, __) => null,
                  onFetchSuccess: (_) => null,
                  onRefreshFailure: (_, __) => null,
                  onRefreshSuccess: (_) => context.snackBar('Refresh success'),
                );
              },
              builder: (context, state, bloc) {
                final comment = state.content!;

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
                            leading: const Icon(Icons.label),
                            title: const Text('Post id'),
                            subtitle: Text(comment.postId.toString()),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.add),
                            title: const Text('Id'),
                            subtitle: Text(comment.id.toString()),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('Name'),
                            subtitle: Text(comment.name),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('Email'),
                            subtitle: Text(comment.email),
                          ),
                          const Divider(),
                          ExpansionTile(
                            leading: const Icon(Icons.message),
                            title: const Text('Body'),
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
