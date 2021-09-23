### 2.2.0 - Sep 23, 2021

-   Update dependencies:
    - `rxdart_ext` to `0.1.2`.
    - `flutter_provider` to `2.1.0`.
-   Change sdk constraint `>=2.14.0 <3.0.0` and flutter constraint `>=2.5.0`.
-   Migrated from `pedantic` to `flutter_lints`.
-   Added `RxStreamBuilder.checkStateStreamEnabled` allows checking invalid state caused by `StateStream`s.
    ```dart
    // enabled when running in debug or profile mode
    RxStreamBuilder.checkStateStreamEnabled = !kReleaseMode;
    ```

## 2.1.1 - May 21, 2021

-   Fix `RxStreamBuilder`: missing pass `Key? key` to parent constructor.

## 2.1.0 - May 10, 2021

-   Update `rxdart` to `0.27.0`.
-   `RxStreamBuilder` now accepts a `ValueStream`.

## 2.0.0 - Mar 3, 2021

-   Stable release for null safety.

## 2.0.0-nullsafety.1 - Jan 21, 2021

-   Makes `RxStreamBuilder` extends `StreamBuilder`.

## 2.0.0-nullsafety.0 - Jan 20, 2021

-   Migrate this package to null safety.
-   Sdk constraints: `>=2.12.0-0 <3.0.0` based on beta release guidelines.
-   Depends on [flutter_provider](https://pub.dev/packages/flutter_provider/versions/2.0.0-nullsafety.0) package.
    So bloc will be created lazy i.e. on the first access.
-   Added extension `BuildContext.bloc<T>({bool listen = false})`. It is identical with `BlocProvider<T>.of(BuildContext, {bool listen = false})`.
-   Changed signature of `builder` in `RxStreamBuilder(builder: )` constructor to `Widget Function(BuildContext, T?)`.
    Previous signature is `Widget Function(BuildContext, AsyncSnapshot<T>)`.
-   Fixed many issues.
-   Many improvements.

## 1.2.0 - Apr 23, 2020

*   Breaking change: support for `rxdart` 0.24.x.

## 1.1.2 - Feb 07, 2020

*   Remove `assert(child != null)` and `@required child` in `BlocProvider` constructor 

## 1.1.1 - Feb 07, 2020

*   Add `DisposeCallbackBaseBloc`
*   Add `BlocProviders`

## 1.1.0 - Dec 17, 2019

*   Update `rxdart`

## 1.0.1 - Aug 10, 2019

*   Minor updates

## 1.0.0+1 - Aug 10, 2019

*   Update README.md

## 1.0.0 - Aug 10, 2019

*   Add `RxStreamBuilder`

## 0.0.1+1 - Feb 08, 2019

*   Add example

## 0.0.1 - Feb 08, 2019

*   Initial
