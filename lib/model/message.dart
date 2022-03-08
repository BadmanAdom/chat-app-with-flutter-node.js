class Message {
  final String message;
  final String sendByMe;


  const Message({
    required this.message,
    required this.sendByMe,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'],
      sendByMe: json['sendByMe'],
    );
  }
}