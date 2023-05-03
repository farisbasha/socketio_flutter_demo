import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatScreen extends StatefulWidget {
  final int conversation_id;
  final int user_id;
  final String otherUserName;

  ChatScreen(
      {required this.conversation_id,
      required this.user_id,
      required this.otherUserName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Socket socket;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initSocket();
    socket.on('messages', (data) {
      print('data: $data');
      if (mounted) {
        setState(() {
          _messages = List.from(data);
        });
      }
    });

    // Request the chat messages for this conversation from the server
    socket.emit('get messages', {'conversation_id': widget.conversation_id});
  }

  void _initSocket() {
    // Initialize the Socket.IO client
    socket = io(
        kIsWeb
            ? 'http://localhost:3000'
            : Platform.isAndroid
                ? "http://10.0.2.2:3000"
                : 'http://localhost:3000',
        OptionBuilder().setTransports(['websocket']) // optional
            .build());

    socket.onConnect((data) {
      print('Connected to Socket.IO server');
      socket.emit('join conversation',
          {'conversation_id': widget.conversation_id.toString()});
    });

    socket.on('chat message', (data) {
      print('Received message from server: $data');

      if (mounted) {
        setState(() {
          _messages.insert(0, data);
        });
      }
    });
    socket.onDisconnect((data) => print('Disconnected from server'));
    socket.connect();
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) {
      return;
    }
    socket.emit('chat message', {
      'conversation_id': widget.conversation_id.toString(),
      'sender_id': widget.user_id.toString(),
      'content': message,
    });
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 28.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                reverse: true,
                itemBuilder: (BuildContext context, int index) {
                  final message = _messages[index];
                  print(message);
                  return MessageTile(
                    message: message,
                    isSender: message['sender_id'] == widget.user_id.toString(),
                  );
                },
              ),
            ),
            Divider(),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _sendMessage(_textController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    print("socketDisconnected Dispose");
    super.dispose();
  }
}

class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
    required this.isSender,
  });

  final Map<String, dynamic> message;
  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        message['content'].toString(),
        style: TextStyle(
          color: isSender ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        message['sent_at'],
        style: TextStyle(
          color: isSender ? Colors.white : Colors.black,
        ),
      ),
      trailing: isSender ? Icon(Icons.check) : null,
      tileColor: isSender ? Colors.blue : Colors.grey[300],
      isThreeLine: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
    );
  }
}
