import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:stream_loader/stream_loader.dart';

import 'data/api.dart';
import 'data/comment.dart';
import 'detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo stream_loader'),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
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
                        ElevatedButton(
                          onPressed: bloc.fetch,
                          child: const Text('Retry'),
                        )
                      ],
                    ),
                  );
                }
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final items = state.content!;

                return RefreshIndicator(
                  onRefresh: bloc.refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final comment = items[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.primaries[index % Colors.primaries.length],
                          maxRadius: 32,
                          minRadius: 32,
                          child: Text(comment.name[0]),
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
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
