<p align="center">
  <img src="https://raw.githubusercontent.com/seifalmotaz/cruky/main/assets/logo/logo_transparent.png" alt="cruky library logo" width="420" height="420" \>
</p>

## Info

Cruky is a server-side library for the dart ecosystem to help you create your API as fast as possible. We want to make server-side apps with modern style and fast `high performance`

> Inspired by Django

## Get started

You can see the todo example in the examples file it's very clear to understand.

1. Install Dart from [Dart.dev](https://dart.dev/)

2. Install the Cruky package with `dart pub global activate cruky_cli`

3. Create dart project with  `dart create nameOfProject`

4. open the project with your favorite IDE like  `vscode`

5. And let's get started

Start adding the entrypoint app

```dart
import 'package:cruky/cruky.dart';

class MyApp extends AppMaterial {
  @override
  List get routes => [
        exampleWithGETRequest,
      ];

  @override
  List get middlewares => [middlewareExample];
}
```

Now let's add our first route method:

```dart
@Route.get('/')
exampleWithGetRequest(ReqCTX req) {
  return Json({});
}
```

Add the `Route` annotation to specify the route path, and add the method under it we can use the `Future` method or regular method (async or sync).

## Return data from the method

You can return a List or map for now and the response content type is just JSON for now.

## Return specific status code

you can return the specific status code with the map like that:

```dart
@Route.post('/')
exampleWithGetRequest(ReqCTX req) {
  return Json({}, 201);
}
```

## Now serve the app

we can serve a simple app with this code

```dart
void main() => run(MyApp());
```

and now run the dart file with `cruky run filename`.

This will run the file in `./bin/filename.dart` with hot-reload.

> You can run with another folder with `cruky run filename -d example`
> 
> This will run the file in `./example/filename.dart`

Now Cruky will run the app with hot-reload if any thing changed in lib folder.

## Let's add some middleware

We can add a before and after middleware.
The before middleware runs before calling the main route method handler,
And the after middleware is the opposite.

```dart
@BeforeMW()
middlewareExample(ReqCTX req) {
  if (req.headerValue('Token') == null) {
    return Text('Not Auth', 401);
  }
}
```

The `MW` is the short of MiddleWare.
The annotiation defines the type of middleware, There is two types `BeforeMW` amd `AfterMW`.

If you want to not execute the next function you can (The main route method) you can return a response like in the example.