# Flutter + Phoenix starter

A small Flutter starter wired to a Phoenix backend. It includes email/password login, secure token storage, Riverpod auth state, GoRouter auth redirects, Dio HTTP requests, and an authenticated Phoenix WebSocket connection.

## Requirements

- Flutter and Dart versions matching the constraints in `pubspec.yaml`
- A Phoenix server running locally

## Configure the local server

Edit `lib/core/config.dart` to match your Phoenix server:

- `apiBaseUrl` is the HTTP API root. The starter app sends login to `POST /api/login` and logout to `POST /api/auth/logout`.
- `socketUrl` is the Phoenix WebSocket endpoint, normally `/socket/websocket`.

The defaults use `localhost:4000`. For Android emulators, use `10.0.2.2` to reach the host machine. For a physical device, use your computer's LAN IP address. These are local development defaults; use your own deployment values when building an app for distribution.

## Expected API response

The login request sends:

```json
{"email":"user@example.com","password":"secret"}
```

The starter expects a successful response in this shape:

```json
{
  "token": "your-auth-token",
  "data": {"email": "user@example.com"}
}
```

`token` must be a non-empty string. `data` is optional and stored as JSON for the example home screen. Adjust `lib/auth/auth_service.dart` if your Phoenix API uses a different endpoint or response format. The logout endpoint is best effort: local credentials are cleared whether or not the server logout request succeeds.

The WebSocket connection sends the token as the `base64url.bearer.phx.<token>` WebSocket subprotocol. Configure the Phoenix socket to accept this authentication method, or change `lib/core/socket_provider.dart` to match your server's authentication strategy.

## Run

Start your Phoenix server, then run:

```sh
flutter pub get
flutter run
```

## Project layout

- `lib/auth/`: auth state and API operations
- `lib/core/`: API/socket configuration, providers, and routing
- `lib/storage/`: secure token and user storage
- `lib/screens/`: example login, home, and splash screens

Replace the example screens and API contract with the needs of your app. Set a unique package/bundle identifier and app branding when creating a distributable application.
