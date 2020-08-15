class ChatModel {
  String id;
  String imageUrl;
  String text;
  String userid;
  String username;
  int timestamp;
  int lastUpdate;
  bool isDone;

  ChatModel(
      {this.id,
      this.imageUrl,
      this.text,
      this.userid,
      this.username,
      this.timestamp,
      this.lastUpdate,
      this.isDone = false});
  ChatModel.fromJson(Map<dynamic, dynamic> json) {
    id = json["\$id"];
    imageUrl = json['imageUrl'];
    text = json['text'];
    userid = json['userid'];
    username = json['username'];
    timestamp = json['timestamp'];
    lastUpdate = json['lastUpdate'];
    isDone = json['isDone'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data["\$id"] = this.id;
    data['imageUrl'] = this.imageUrl;
    data['text'] = this.text;
    data['userid'] = this.userid;
    data['username'] = this.username;
    data['timestamp'] = this.timestamp;
    data['lastUpdate'] = this.lastUpdate;
    data['isDone'] = this.isDone;
    return data;
  }
}
