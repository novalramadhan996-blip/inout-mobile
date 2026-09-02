class Chat {
  String? name;
  String? message;
  String? imageUrl;
  String? time;
  bool? onStatus;

  Chat({this.name, this.message, this.imageUrl, this.time, this.onStatus});

  Chat.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    message = json['message'];
    imageUrl = json['imageUrl'];
    time = json['time'];
    onStatus = json['onStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['message'] = message;
    data['imageUrl'] = imageUrl;
    data['time'] = time;
    data['onStatus'] = onStatus;
    return data;
  }
}