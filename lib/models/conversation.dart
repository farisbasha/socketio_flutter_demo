class Conversation {
  Conversation({
    required this.id,
    required this.startedAt,
    required this.currentUser,
    required this.targetUser,
  });
  late final int id;
  late final String startedAt;
  late final int currentUser;
  late final TargetUser targetUser;

  Conversation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startedAt = json['started_at'];
    currentUser = json['current_user'];
    targetUser = TargetUser.fromJson(json['target_user']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['started_at'] = startedAt;
    _data['current_user'] = currentUser;
    _data['target_user'] = targetUser.toJson();
    return _data;
  }
}

class TargetUser {
  TargetUser({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  TargetUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}
