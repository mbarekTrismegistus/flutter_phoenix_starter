import 'dart:convert';

import 'package:dart_phoenix_socket/dart_phoenix_socket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:__PROJECT_NAME__/auth/auth_provider.dart';
import 'package:__PROJECT_NAME__/core/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketNotifier extends Notifier<PhoenixSocket?> {
  @override
  PhoenixSocket? build() {
    final auth = ref.watch(authProvider).value;
    if (auth is! Authenticated) return null;

    final socket = PhoenixSocket(
      socketUrl,
      channelFactory: (uri) {
        return WebSocketChannel.connect(
          uri,
          protocols: [
            'phoenix',
            'base64url.bearer.phx.${base64Url.encode(utf8.encode(auth.token)).replaceAll('=', '')}',
          ],
        );
      },
    );
    ref.onDispose(socket.disconnect);
    socket.connect();
    return socket;
  }
}

final socketProvider = NotifierProvider<SocketNotifier, PhoenixSocket?>(
  SocketNotifier.new,
);
