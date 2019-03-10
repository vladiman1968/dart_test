import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpException;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:chat_models/chat_models.dart';
import 'package:chat_web/routes.dart';
import 'package:chat_web/services.dart';

@Component(selector: 'chat', templateUrl: 'chat_component.html', styleUrls: [
  'chat_component.css'
], directives: [
  coreDirectives,
  materialInputDirectives,
  MaterialButtonComponent,
  MaterialIconComponent
], pipes: [
  DatePipe
], providers: [
  materialProviders,
  ClassProvider(WebChatsClient),
  ClassProvider(WebMessagesClient)
])
class ChatComponent implements OnActivate, OnDeactivate {
  WebChatsClient chatsClient;
  WebMessagesClient messagesClient;
  Api api;
  Router router;
  Session session;
  ChatId chatId;
  Chat chat;
  String chatMembers;
  StreamSubscription subscription;
  List<Message> messages;
  String newMessageText = '';

  ChatComponent(this.chatsClient, this.messagesClient, this.api, this.router, this.session);

  String messageClassName(String messageAuthorName) {
    if (messageAuthorName != session.currentUser.name) return 'message-right';
    return 'message-left';
  }

  send() async {
    final newMessage = Message(
        chat: chatId,
        author: session.currentUser,
        text: newMessageText,
        createdAt: DateTime.now());
    try {
      final createdMessage = await messagesClient.create(newMessage);
      messages.add(createdMessage);
    } on HttpException catch (e) {
      print('Sending message failed');
      print(e);
    }

    newMessageText = '';
  }

  toChatList() {
    router.navigate(RoutePaths.chats.toUrl());
  }

  @override
  onActivate(_, RouterState current) async {
    chatId = ChatId(current.parameters['chatId']);
    chat = await chatsClient.read(chatId);
    chatMembers = chat.members.map((user) => user.name).join(', ');
    messages = await messagesClient.read(chatId);

    subscription = api.newMessageData.listen((data) {
      final receivedMessage = Message.fromJson(json.decode(data));
      receivedMessage.chat != chatId ?
        api.sendNotification(chat.title, receivedMessage.text)
      :
        messages.add(receivedMessage);
    });
  }

  @override
  onDeactivate(RouterState current, _) {
    subscription.cancel();
  }
}
