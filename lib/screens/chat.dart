import 'package:flutter/material.dart';
import 'package:frontend/Controller/chat_controller.dart';
import 'package:frontend/model/message.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _msgController = TextEditingController();
  late IO.Socket socket;
  ChatController chatController = ChatController();

  @override
  void initState() {
    socket = IO.io(
        'http://localhost:4000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
    setUpSocketListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: Column(
            children: [
              Expanded(
                  child: Obx(
                () => Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Connected User ${chatController.connectedUser}',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              )),
              Expanded(
                flex: 9,
                child: Obx(() => ListView.builder(
                    itemCount: chatController.chatMessages.length,
                    itemBuilder: (context, index) {
                      var currentItem = chatController.chatMessages[index];
                      return MessageItem(
                        sendByMe: currentItem.sendByMe == socket.id,
                        message: currentItem.message,
                      );
                    })),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(12),
                child: TextFormField(
                  style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),
                  controller: _msgController,
                  decoration: InputDecoration(
                      focusedBorder: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(18)),
                      suffixIcon: Container(
                        margin: EdgeInsets.all(2),
                        child: IconButton(
                          color: Colors.white,
                          onPressed: () {
                            sendMessage(_msgController.text);
                            _msgController.text = '';
                          },
                          icon: Icon(Icons.send),
                        ),
                      )),
                ),
              ))
            ],
          ),
        ));
  }

  void sendMessage(String text) {
    var messageJson = {'message': text, 'sendByMe': socket.id};
    socket.emit('message', messageJson);
    chatController.chatMessages.add(Message.fromJson(messageJson));
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data) {
      print(data);
      chatController.chatMessages.add(Message.fromJson(data));
    });
    socket.on('connected-user', (data) {
      print(data);
      chatController.connectedUser.value = data;
    });
  }
}

class MessageItem extends StatelessWidget {
  const  MessageItem({Key? key, required this.sendByMe, required this.message})
      : super(key: key);
  final bool sendByMe;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
            color: sendByMe ? Colors.purple : Colors.white,
            borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(color: sendByMe ? Colors.white : Colors.purple),
            ),
            SizedBox(
              width: 10,
            ),
            Text('1:10 AM',
                style: TextStyle(
                    color: (sendByMe ? Colors.white : Colors.purple)
                        .withOpacity(0.7),
                    fontSize: 10))
          ],
        ),
      ),
    );
  }
}
