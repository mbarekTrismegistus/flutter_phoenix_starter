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

## Dependency versions

This starter includes `pubspec.lock` so generated apps start from a dependency set that has been resolved together. Keep the lockfile in the starter. Users can update compatible dependencies when they choose with:

```sh
flutter pub upgrade
flutter analyze
flutter test
```

Update dependency constraints and the lockfile in this template periodically, then verify and publish a new template/brick version. Avoid resolving to the newest versions automatically during generation: upstream releases can introduce breaking changes and make generated projects less reproducible.

## Publish this starter as a GitHub template

1. Push this project to a GitHub repository and make the repository public.
2. Open the repository's **Settings → General** page.
3. Under **Template repository**, enable **Template repository** and save.
4. Share the repository URL. Users can select **Use this template → Create a new repository** to start a project from it.

GitHub templates copy the files into a new repository with a fresh history. See [GitHub's template repository guide](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).

## Turn it into a Mason generator

Mason generators are called bricks. To make one from this starter:

1. Install Mason CLI: `dart pub global activate mason_cli`.
2. Create a brick scaffold in a separate directory: `mason new phoenix_flutter`.
3. Copy the starter project files into `phoenix_flutter/__brick__/`. Leave Mason metadata files such as `brick.yaml`, `README.md`, `LICENSE`, and `CHANGELOG.md` at the brick root. Exclude generated/cache folders such as `.dart_tool/`, `build/`, and `.git/`.
4. Edit `phoenix_flutter/brick.yaml` with a unique brick name, description, version, repository URL, and prompts for values such as the app display name, Dart package name, and Phoenix host.
5. Replace the corresponding values in files under `__brick__/` with Mason variables. Check platform identifiers, package imports, app labels, and README examples as well as `pubspec.yaml` and `lib/core/config.dart`.
6. Generate into a clean temporary directory with `mason make phoenix_flutter --output-dir /tmp/generated_app`, then run `flutter pub get`, `flutter analyze`, and `flutter test` there. Fix generation issues before publishing.
7. Publish the source repository publicly. Sign up and verify an account at [BrickHub](https://brickhub.dev), then log in with `mason login`.
8. Publish the brick with `mason publish --directory phoenix_flutter`.

Users install and run the published brick with:

```sh
mason add phoenix_flutter
mason make phoenix_flutter
```

Mason prompts for any variables the user did not pass on the command line. Bump the version in `brick.yaml` each time you publish an updated brick. See the [Mason brick structure guide](https://docs.brickhub.dev/brick-structure/) and [BrickHub publishing guide](https://docs.brickhub.dev/mason-publish/) for current details.
