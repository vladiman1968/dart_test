import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:rest_api_server/annotations.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:chat_models/chat_models.dart';

import 'chats_resource.dart';
import 'users_resource.dart';

/// Root API resource
class ApiResource {
  final ChatsResource _chatsResource;
  final UsersResource _usersResource;
  final Map<UserId, List<WebSocketChannel>> _webSockets;
  UserId userId;
  shelf.Handler _wsConnectionHandler;

  ApiResource(
      {ChatsResource chatsResource,
      UsersResource usersResource,
        Map<UserId, List<WebSocketChannel>> webSockets})
      : _chatsResource = chatsResource,
        _usersResource = usersResource,
        _webSockets = webSockets {
          _wsConnectionHandler = webSocketHandler((WebSocketChannel wsChannel) {
            if (!(_webSockets.containsKey(userId)))
              _webSockets[userId] = <WebSocketChannel>[];
            _webSockets[userId].add(wsChannel);
        });
  }

  /// Chats resource
  @Resource(path: 'chats')
  ChatsResource get chatsResource => _chatsResource;

  /// Users resource
  @Resource(path: 'users')
  UsersResource get usersResource => _usersResource;

  /// Handles web-socket connection request
  @Get(path: 'ws')
  shelf.Response handleUpgradeRequest(shelf.Request request, Map context) {
    userId = UserId(verifyJwtHS256Signature(
        request.requestedUri.queryParameters['token'], 'secret key')
        .subject);
    return _wsConnectionHandler(request);
  }
}
