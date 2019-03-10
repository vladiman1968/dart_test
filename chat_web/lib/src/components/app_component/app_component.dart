import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:chat_web/routes.dart';
import 'package:chat_web/services.dart';

@Component(
    selector: 'my-app',
    styleUrls: [
      'package:angular_components/app_layout/layout.scss.css',
      'app_component.css'
    ],
    templateUrl: 'app_component.html',
    directives: [
      coreDirectives,
      MaterialButtonComponent,
      MaterialIconComponent,
      routerDirectives
    ],
    providers: [
      ClassProvider(WebApiClient),
      ClassProvider(Api),
      ClassProvider(Session)
    ],
    exports: [RoutePaths, Routes])
class AppComponent {
  Api api;
  Session session;
  AppComponent(this.api, this.session);

  signOut() {
    session.clear();
    api.closeWebSocket();
  }
}
