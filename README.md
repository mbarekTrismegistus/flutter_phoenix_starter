# Flutter + Phoenix Starter

Flutter starter with Riverpod auth state, GoRouter, Dio, secure token storage, and Phoenix WebSocket support.

## Configure

Set the backend URLs in `lib/core/config.dart`:

- `apiBaseUrl`: HTTP API root
- `socketUrl`: Phoenix WebSocket endpoint

Defaults use `localhost:4000`. Android emulators use `10.0.2.2` to reach the host machine. Physical devices require the host machine's LAN IP.

Login sends `POST /api/login` with `email` and `password`. The response must include a non-empty `token`; optional `data` must be a JSON object. Logout uses `POST /api/auth/logout`. Update `lib/auth/auth_service.dart` to match a different API contract.

The WebSocket sends the token using the `base64url.bearer.phx.<token>` subprotocol. Configure Phoenix to accept it or update `lib/core/socket_provider.dart`.

## Run

```sh
flutter pub get
flutter run
```

## Dependencies

`pubspec.lock` pins the starter's resolved dependencies. To update compatible dependencies:

```sh
flutter pub upgrade
flutter analyze
flutter test
```

Commit the updated lockfile after verification. Avoid automatic dependency upgrades during generation.
