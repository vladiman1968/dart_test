import 'package:rest_api_server/annotations.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chats_resource.dart';
import 'users_resource.dart';

/// Root API resource
class ApiResource {
  final ChatsResource _chatsResource;
  final UsersResource _usersResource;
  final List<WebSocketChannel> _wsChannels;
  shelf.Handler _wsConnectionHandler;

  ApiResource(
      {ChatsResource chatsResource,
      UsersResource usersResource,
      List<WebSocketChannel> wsChannels})
      : _chatsResource = chatsResource,
        _usersResource = usersResource,
        _wsChannels = wsChannels {
    _wsConnectionHandler = webSocketHandler((WebSocketChannel wsChannel) {
      _wsChannels.add(wsChannel);
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
    return _wsConnectionHandler(request);
  }
}
