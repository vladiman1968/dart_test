import 'dart:async';
import 'dart:convert';

import 'package:chat_api/collections.dart';
import 'package:chat_api/helpers.dart';
import 'package:chat_models/chat_models.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:rest_api_server/annotations.dart';
import 'package:rest_api_server/http_exception.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Messages resource
class MessagesResource {
  MessagesCollection messagesCollection;
  ChatsCollection chatsCollection;
  //List<WebSocketChannel> wsChannels;
  Map<UserId, List<WebSocketChannel>> webSockets;

  MessagesResource(
      //{this.chatsCollection, this.messagesCollection, this.wsChannels});
      {this.chatsCollection, this.messagesCollection, this.webSockets});

  /// Creates new message in database
  @Post()
  Future<Message> create(String chatIdStr, Map requestBody, Map context) async {
    final currentUser = User.fromJson(context['payload']);
    if (currentUser == null) throw (ForbiddenException());
    requestBody['createdAt'] = DateTime.now();
    final newMessage = Message.fromJson(requestBody);
    if (newMessage.author.id != currentUser.id) throw (ForbiddenException());
    if (newMessage.chat != ChatId(chatIdStr))
      throw (BadRequestException({}, 'Wrong chat'));
    final createdMessage = await messagesCollection.insert(newMessage);
    Chat chat = await chatsCollection.findOne(createdMessage.chat);
    chat.members.forEach((user) {
      UserId userId = user.id;
      if ((userId != currentUser.id) && (webSockets.containsKey(userId))) {
        webSockets[userId].forEach((wsChannel) {
          wsChannel.sink
              .add(json.encode(createdMessage.json, toEncodable: toEncodable));
        });
      }
    });
    return createdMessage;
  }

  /// Reads messages from database
  @Get()
  Future<List<Message>> read(String chatIdStr, Map context) async {
    final currentUser = User.fromJson(context['payload']);
    if (currentUser == null) throw (ForbiddenException());
    final chatId = ChatId(chatIdStr);
    final chat = await chatsCollection.findOne(chatId);
    if (!chat.members.any((member) => member.id == currentUser.id))
      throw (ForbiddenException());
    final query = mongo.where.eq('chat', chatId.json);
    return messagesCollection.find(query).toList();
  }
}
