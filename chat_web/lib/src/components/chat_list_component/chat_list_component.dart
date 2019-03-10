import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpException;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:chat_models/chat_models.dart';
import 'package:chat_web/components.dart';
import 'package:chat_web/routes.dart';
import 'package:chat_web/services.dart';

@Component(
    selector: 'chat-list',
    templateUrl: 'chat_list_component.html',
    styleUrls: [
      'chat_list_component.css'
    ],
    directives: [
      coreDirectives,
      materialInputDirectives,
      MaterialListComponent,
      MaterialListItemComponent,
      MaterialButtonComponent,
      MaterialFabComponent,
      MaterialIconComponent,
      MaterialDialogComponent,
      ModalComponent,
      UsersListComponent
    ],
    providers: [
      overlayBindings,
      ClassProvider(WebChatsClient)
    ])
class ChatListComponent implements OnActivate, OnDeactivate {
  Api api;
  Session session;
  WebChatsClient chatsClient;
  Router router;

  List<Chat> chats = [];
  StreamSubscription subscription;
  String newChatTitle = '';
  bool showCreateChatDialog = false;

  @ViewChild(UsersListComponent)
  UsersListComponent usersList;

  ChatListComponent(this.api, this.session, this.chatsClient, this.router);

  String getChatMembers(ChatId chatId) => chats
      .firstWhere((chat) => chat.id == chatId)
      .members
      .map((user) => user.name)
      .join(', ');

  void selectChat(ChatId chatId) {
    router.navigate(RoutePaths.chat.toUrl(parameters: {'chatId': chatId.json}));
  }

  void createChat() async {
    try {
      final newChat = await chatsClient.create(Chat(
          title: newChatTitle,
          members: usersList.selectedUsers.selectedValues.toList()
            ..add(session.currentUser)));
      chats.add(newChat);
      selectChat(newChat.id);
    } on HttpException catch (e) {
      print('Chat creation failed');
      print(e);
    }
  }

  @override
  onActivate(_, RouterState current) async {
    try {
      chats = await chatsClient.read({});

      subscription = api.newMessageData.listen((data) {
        final receivedMessage = Message.fromJson(json.decode(data));
        api.sendNotification(
          chats.firstWhere((chat) => chat.id == receivedMessage.chat).title,
          receivedMessage.text
        );
      });

    } on HttpException catch (e) {
      print('Getting chat list failed');
      print(e);
    }
  }

  @override
  onDeactivate(RouterState current, _) {
    subscription.cancel();
  }
}
