import 'package:angular/angular.dart';
import 'package:chat_api_client/chat_api_client.dart';

import 'web_api_client.dart';

@Injectable()
class WebUsersClient extends UsersClient {
  WebUsersClient(WebApiClient apiClient) : super(apiClient);
}
