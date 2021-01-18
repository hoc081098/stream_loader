## 1.1.0-nullsafety.0 - Jan 18, 2021
*   Migrate this package to null safety.
*   Sdk constraints: `>=2.12.0-0 <3.0.0` based on beta release guidelines.
*   `LoaderMessage.fold` requires all arguments are not null.
*   Dependencies:
    -   Depends on [rxdart_ext](https://pub.dev/packages/rxdart_ext). 
    -   Removed [built_value](https://pub.dev/packages/built_value).

## 1.1.0-beta02 - Dec 17, 2020
*   Update dependencies to latest version.
*   Breaking change: changed `LoaderBloc({ bool enableLogger })` to `LoaderBloc({ void Function(String) logger })`.

## 1.1.0-beta01 - Oct 18, 2020

*   Update dependencies to latest version.
*   `LoaderBloc.state$` will not replay the latest state, use `LoaderBloc.state$.value` getter instead. 
    This is more consistent to `StreamBuilder.initialData` in Flutter.
    This change caused by change of [distinct_value_connectable_stream 1.2.0-beta01](https://pub.dev/packages/distinct_value_connectable_stream/versions/1.2.0-beta01/changelog).

## 1.0.1 - Sep 22, 2020

* Update dependencies.

## 1.0.0 - Apr 29, 2020

* Update dependencies.

## 0.1.0 - Jan 12, 2020

* Add documents.
* Add tests.
* Minor updates.

## 0.0.1 - Jan 12, 2020

* Publish.
