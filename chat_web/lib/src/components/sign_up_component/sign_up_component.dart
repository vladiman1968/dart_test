import 'dart:io' show HttpException;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:chat_models/chat_models.dart';
import 'package:chat_web/routes.dart';
import 'package:chat_web/services.dart';

@Component(
    selector: 'sign-up',
    templateUrl: 'sign_up_component.html',
    styleUrls: [
      'sign_up_component.css'
    ],
    directives: [
      MaterialButtonComponent,
      materialInputDirectives,
    ],
    providers: [
      ClassProvider(WebUsersClient),
    ])
class SignUpComponent {
  String name = '';
  String password = '';
  WebUsersClient usersClient;
  Session session;
  Router router;

  SignUpComponent(this.usersClient, this.session, this.router);

  signUp() async {
    try {
      await usersClient.create(User(name: name, password: password));
      router.navigate(RoutePaths.signIn.toUrl());
    } on HttpException catch (e) {
      print('Signup failed');
      print(e);
    }
  }
}
