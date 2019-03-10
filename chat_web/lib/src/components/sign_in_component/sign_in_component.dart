import 'dart:io' show HttpException;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:chat_web/routes.dart';
import 'package:chat_web/services.dart';

@Component(
    selector: 'sign-in',
    templateUrl: 'sign_in_component.html',
    styleUrls: [
      'sign_in_component.css'
    ],
    directives: [
      MaterialButtonComponent,
      materialInputDirectives,
      routerDirectives
    ],
    providers: [
      ClassProvider(WebUsersClient),
    ],
    exports: [
      RoutePaths
    ])
class SignInComponent {
  String username = '';
  String password = '';
  WebUsersClient usersClient;
  Api api;
  Router router;
  Session session;

  SignInComponent(this.usersClient, this.api, this.router, this.session);

  signIn() async {
    try {
      var user = await usersClient.login(username, password);
      session.currentUser = user;
      api.addWebSocket();
      router.navigate(RoutePaths.chats.toUrl());
    } on HttpException catch (e) {
      print('Login failed');
      print(e);
    }
  }
}
