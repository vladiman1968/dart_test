import 'package:data_model/data_model.dart';

class User implements Model<UserId> {
  UserId id;
  String name;
  String password;
  User({this.id, this.name, this.password});
  factory User.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return User(
        id: UserId(json['id']), name: json['name'], password: json['password']);
  }

  Map<String, dynamic> get json => {
        'id': id?.json,
        'name': name,
        'password': password
      }..removeWhere((key, value) => value == null);
}

class UserId extends ObjectId {
  UserId._(id) : super(id);
  factory UserId(id) {
    if (id == null) return null;
    return UserId._(id);
  }
}
