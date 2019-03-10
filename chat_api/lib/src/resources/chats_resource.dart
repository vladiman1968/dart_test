import 'dart:async';

import 'package:chat_api/collections.dart';
import 'package:chat_models/chat_models.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:rest_api_server/annotations.dart';
import 'package:rest_api_server/http_exception.dart';

import 'messages_resource.dart';

/// Chats resource
class ChatsResource {
  final ChatsCollection chatsCollection;
  final MessagesResource _messagesResource;

  ChatsResource({this.chatsCollection, MessagesResource messagesResource})
      : _messagesResource = messagesResource;

  /// Reads chat objects from database
  @Get()
  Future<List<Chat>> read(Map context) {
    final currentUser = User.fromJson(context['payload']);
    if (currentUser == null) throw (ForbiddenException());
    final query = mongo.where.eq('members', currentUser.id.json);
    return chatsCollection.find(query).toList();
  }

  /// Reads chat object from database
  @Get(path: '{chatIdStr}')
  Future<Chat> readChat(String chatIdStr, Map context) async {
    final currentUser = User.fromJson(context['payload']);
    if (currentUser == null) throw (ForbiddenException());
    final chatId = ChatId(chatIdStr);
    return await chatsCollection.findOne(chatId);
  }

  /// Creates new chat in database
  @Post()
  Future<Chat> create(Map requestBody, Map context) async {
    final currentUser = User.fromJson(context['payload']);
    if (currentUser == null) throw (ForbiddenException());
    final newChat = Chat.fromJson(requestBody);
    if (!newChat.members.any((member) => member.id == currentUser.id))
      throw (BadRequestException(
          {}, 'Current user must be a member of new chat'));
    final query = mongo.where
        .all('members', newChat.members.map((user) => user.id.json).toList());
    final found = await chatsCollection.find(query).toList();
    if (found.length != 0) return found.first;
    return chatsCollection.insert(newChat);
  }

  /// Chat messages resource
  @Resource(path: '{chatIdStr}/messages')
  MessagesResource get messagesResource => _messagesResource;
}
