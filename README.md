# stream_loader ![alt text](https://avatars3.githubusercontent.com/u/6407041?s=32&v=4)

A flutter plugin for loading content asynchronously with Dart stream.

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

## Usage

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
    initialContent: BuiltList.of([]),
    enableLogger: true,
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
    enableLogger: true,
  ),
  messageHandler: (message, _) {
    message.fold(
      onFetchFailure: null,
      onFetchSuccess: null,
      onRefreshFailure: null,
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

## License
    MIT License
    
    Copyright (c) 2020 Petrus Nguyễn Thái Học
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
