# phoenix_flutter

Generate Flutter projects preconfigured for Phoenix authentication, Dio HTTP requests, secure token storage, and Phoenix WebSocket support.

Requires Dart 3.13.5 or newer and Flutter on `PATH`.

## Generate a project

```sh
dart run phoenix_flutter:phoenix_create@ create my_app \
  --org com.acme \
  --title "My App" \
  --api-host localhost:4000
```

The command creates `my_app/`, substitutes the supplied values, and runs `flutter pub get`. Then start the app:

```sh
cd my_app
flutter run
```

The [example](example/create_project.dart) runs the same generator command from a Dart script.

Options:

- `--org`: reverse-domain organization ID, such as `com.acme` (default: `com.example`)
- `--title`: app display name (default: derived from the project name)
- `--api-host`: Phoenix host and port without a scheme (default: `localhost:4000`)
- `--output`: destination directory (default: project name)

Install the command globally with `dart install phoenix_flutter`, then run:

```sh
phoenix_create create my_app --org com.acme --title "My App" --api-host localhost:4000
```
