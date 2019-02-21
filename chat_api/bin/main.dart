import 'dart:io';

import 'package:chat_api/collections.dart';
import 'package:chat_api/resources.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:rest_api_server/api_server.dart';
import 'package:rest_api_server/auth_middleware.dart';
import 'package:rest_api_server/cors_headers_middleware.dart';
import 'package:rest_api_server/http_exception_middleware.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:web_socket_channel/web_socket_channel.dart';

main() async {
  final db = mongo.Db('mongodb://localhost:27017/simple_chat');
  await db.open();
  final chatsCollection = ChatsCollection(mongo.DbCollection(db, 'chats'));
  final messagesCollection =
      MessagesCollection(mongo.DbCollection(db, 'messages'));
  final usersCollection = UsersCollection(mongo.DbCollection(db, 'users'));
  final wsChannels = <WebSocketChannel>[];
  final router = Router();
  router.add(ApiResource(
      chatsResource: ChatsResource(
        chatsCollection: chatsCollection,
        messagesResource: MessagesResource(
            chatsCollection: chatsCollection,
            messagesCollection: messagesCollection,
            wsChannels: wsChannels),
      ),
      usersResource: UsersResource(usersCollection: usersCollection),
      wsChannels: wsChannels));

  final server = ApiServer(
      address: InternetAddress.anyIPv4,
      port: 3333,
      handler: shelf.Pipeline()
          .addMiddleware(CorsHeadersMiddleware({
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Expose-Headers': 'Authorization, Content-Type',
            'Access-Control-Allow-Headers':
                'Authorization, Origin, X-Requested-With, Content-Type, Accept, Content-Disposition',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE'
          }))
          .addMiddleware(HttpExceptionMiddleware())
          .addMiddleware(AuthMiddleware(
              loginPath: '/users/login',
              exclude: {
                'POST': ['/users/login', '/users'],
                'GET': ['/ws']
              },
              jwt: Jwt(
                  securityKey: 'secret key',
                  issuer: 'Simple Chat',
                  maxAge: Duration(hours: 1))))
          .addHandler(router.handler));

  await server.start();
  router.printRoutes();
}
