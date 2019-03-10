import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:web_socket_channel/html.dart';
import 'package:chat_web/services.dart';

@Injectable()
class Api {
  HtmlWebSocketChannel webSocketChannel;
  Session session;
  StreamController newMessageEventController;
  Stream newMessageData;

  Api(this.session) {
    newMessageEventController = new StreamController.broadcast();
    newMessageData = newMessageEventController.stream;
  }

  void addWebSocket() {
    String jwtToken = session.authToken;
    webSocketChannel = HtmlWebSocketChannel.connect('ws://localhost:3333/ws?token=$jwtToken');
    webSocketChannel.stream.listen((data) {
      newMessageEventController.add(data);
    });
  }

  void closeWebSocket() {
    webSocketChannel.sink.close();
  }

  Notification sendNotification(String chatName, messageText) {
    return new Notification(chatName, body: messageText, icon: 'user.png');
  }
}