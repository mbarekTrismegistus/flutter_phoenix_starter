# Flutter + Phoenix Starter

Flutter starter and project generator with Riverpod auth state, GoRouter, Dio, secure token storage, and Phoenix WebSocket support.

## Generate a project

With Dart 3.13.5 or newer and Flutter on `PATH`, run:

```sh
dart run phoenix_flutter:phoenix_create@ create my_app \
  --org com.acme \
  --title "My App" \
  --api-host localhost:4000
```

This creates `my_app/`, fills in the project name, organization ID, app title, and Phoenix host, then runs `flutter pub get`.

Options:

- `--org`: reverse-domain organization ID, such as `com.acme` (default: `com.example`)
- `--title`: app display name (default: derived from the project name)
- `--api-host`: Phoenix host and port without a scheme (default: `localhost:4000`)
- `--output`: output directory (default: project name)

Run the generated app with:

```sh
cd my_app
flutter run
```

To install the generator command globally instead:

```sh
dart install phoenix_flutter
phoenix_create create my_app --org com.acme
```

## Phoenix API contract

The starter sends login to `POST /api/login` with `email` and `password`. The response must contain a non-empty `token`; optional `data` must be a JSON object. Logout uses `POST /api/auth/logout`. Update `lib/auth/auth_service.dart` if the backend uses a different contract.

The WebSocket sends the token using the `base64url.bearer.phx.<token>` subprotocol. Configure Phoenix to accept it or update `lib/core/socket_provider.dart`.

## Local development

Set `apiBaseUrl` and `socketUrl` in `lib/core/config.dart`. Android emulators use `10.0.2.2:4000` to reach a Phoenix server running on the host machine. Physical devices require the host machine's LAN IP.

The starter's `pubspec.lock` pins its resolved dependencies. Update compatible versions with `flutter pub upgrade`, then run `flutter analyze` and `flutter test` before updating the template.
