# stream_loader ![alt text](https://avatars3.githubusercontent.com/u/6407041?s=32&v=4)

A flutter plugin for loading content asynchronously with Dart stream. `RxDart` loader bloc.

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)

[![Pub](https://img.shields.io/pub/v/stream_loader.svg)](https://pub.dartlang.org/packages/stream_loader)
[![Build Status](https://travis-ci.org/hoc081098/stream_loader.svg?branch=master)](https://travis-ci.org/hoc081098/stream_loader)
[![codecov](https://codecov.io/gh/hoc081098/stream_loader/branch/master/graph/badge.svg)](https://codecov.io/gh/hoc081098/stream_loader)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Getting Started

In your flutter project, add the dependency to your `pubspec.yaml`

```yaml
dependencies:
  ...
  stream_loader: <latest_version>
```

## Examples
-   [stream_loader/example](https://github.com/hoc081098/stream_loader/tree/master/example)
-   [stream_loader_demo](https://github.com/hoc081098/stream_loader_demo)

## Usage

<p align="center">
    <img src="https://github.com/hoc081098/hoc081098.github.io/raw/master/stream_loader/untitled.gif" height="480"/>
</p>

#### Model and api
```dart
abstract class Comment implements Built<Comment, CommentBuilder> { ... }

class Api {
  Stream<BuiltList<Comment>> getComments() { ... }
  Stream<Comment> getCommentBy({@required int id}) { ... }
}
final api = Api();
```

#### Create LoaderWidget load comments from api
```dart
import 'package:stream_loader/stream_loader.dart';

LoaderWidget<BuiltList<Comment>>(
  blocProvider: () => LoaderBloc(
    loaderFunction: api.getComments,
    refresherFunction: api.getComments,
    initialContent: <Comment>[].build(),
    logger: print,
  ),
  messageHandler: (message, bloc) {
    message.fold(
      onFetchFailure: (error, stackTrace) => context.snackBar('Fetch error'),
      onFetchSuccess: (_) {},
      onRefreshSuccess: (data) => context.snackBar('Refresh success'),
      onRefreshFailure: (error, stackTrace) => context.snackBar('Refresh error'),
    );
  },
  builder: (context, state, bloc) {
    if (state.error != null) {
      return ErrorWidget(error: state.error);
    }
    if (state.isLoading) {
      return LoadingWidget();
    }
    return RefreshIndicator(
      onRefresh: bloc.refresh,
      child: CommentsListWidget(comments: state.content),
    );
  }
);
```

#### Create LoaderWidget load comment detail from api
```dart
import 'package:stream_loader/stream_loader.dart';

final Comment comment;
final loadDetail = () => api.getCommentBy(id: comment.id);

LoaderWidget<Comment>(
  blocProvider: () => LoaderBloc(
    loaderFunction: loadDetail,
    refresherFunction: loadDetail,
    initialContent: comment,
    logger: print,
  ),
  messageHandler: (message, _) {
    message.fold(
      onFetchFailure: (_, __) {},
      onFetchSuccess: (_) {},
      onRefreshFailure: (_, __) {},
      onRefreshSuccess: (_) => context.snackBar('Refresh success'),
    );
  },
  builder: (context, state, bloc) {
    return RefreshIndicator(
      onRefresh: bloc.refresh,
      child: CommentDetailWidget(comment: state.content),
    );
  },
);
```

#### Note: Can use `LoaderBloc` without `LoaderWidget` easily
```dart

class _CommentsState extends State<Comments> {
  LoaderBloc<BuiltList<Comment>> bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    bloc ??= LoaderBloc(
      loaderFunction: api.getComments,
      refresherFunction: api.getComments,
      initialContent: <Comment>[].build(),
      logger: print,
    )..fetch();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoaderState<BuiltList<Comment>>>(
      stream: bloc.state$,
      initialData: bloc.state$.value, // <- required because bloc.state$ does not replay the latest value
      builder: (context, snapshot) {
        final state = snapshot.data;
        
        if (state.error != null) {
          return ErrorWidget(error: state.error);
        }
        if (state.isLoading) {
          return LoadingWidget();
        }
        return RefreshIndicator(
          onRefresh: bloc.refresh,
          child: CommentsListWidget(comments: state.content),
        );
      }
    );
  }
}
```

## License
    MIT License
    
    Copyright (c) 2020 Petrus Nguyễn Thái Học
