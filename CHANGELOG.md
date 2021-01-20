## 2.0.0-nullsafety.0 - Jan 20, 2021

-   Migrate this package to null safety.
-   Sdk constraints: `>=2.12.0-0 <3.0.0` based on beta release guidelines.
-   Depends on [flutter_provider](https://pub.dev/packages/flutter_provider/versions/2.0.0-nullsafety.0) package.
    So bloc will be created lazy i.e. on the first access.
-   Added extension `BuildContext.bloc<T>({bool listen = false})`. It is identical with `BlocProvider<T>.of(BuildContext, {bool listen = false})`.
-   Changed signature of `builder` in `RxStreamBuilder(builder: )` constructor to `Widget Function(BuildContext, T?)` ~ 
    `Widget Function(BuildContext, AsyncSnapshot<T>)` before.
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
