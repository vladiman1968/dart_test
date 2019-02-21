import 'package:angular/angular.dart';
import 'package:chat_api_client/chat_api_client.dart';

import 'web_api_client.dart';

@Injectable()
class WebChatsClient extends ChatsClient {
  WebChatsClient(WebApiClient apiClient) : super(apiClient);
}
