## 1.4.0 - Sep 15, 2021

*   Remove `distinct_value_connectable_stream` dependency.
*   Update dependencies
    * `rxdart_ext` to `0.1.2`
    * `rxdart` to `0.27.2`
    * `meta` to `1.7.0`
*   Migrated from `pedantic` to `flutter_lints`.

## 1.3.0 - Jun 21, 2021

*   Rename `FlatMapPolicy` to `FlattenStrategy`.
*   Fix `LoaderBloc.refresh()` does not complete.

## 1.2.1 - Jun 17, 2021

*   Change `dispose` from a field to a function.
*   Add `FlatMapPolicy` allow changing _flatMap behavior_ of `loaderFunction` and `refresherFunction`.
    ```dart
    LoaderBloc(
      ...,
      loaderFlatMapPolicy: FlatMapPolicy.concat, // asyncExpand
      refreshFlatMapPolicy: FlatMapPolicy.latest, // switchMap
    );
    ```

## 1.2.0 - May 10, 2021

*   Update `rxdart` to `0.27.0`.

## 1.1.0 - Mar 27, 2021

*   Stable release for null safety.

## 1.1.0-nullsafety.2 - Feb 18, 2021

*   Latest dependencies.

## 1.1.0-nullsafety.1 - Jan 23, 2021

*   **Breaking**: changed signature of `LoaderMessageHandler` to `void Function(BuildContext, LoaderMessage, LoaderBloc)`.
    This allows using `BuildContext` to access ancestor widget, eg. `ScaffoldMessenger.of(context)`, `Navigator.of(context)`, ...

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
