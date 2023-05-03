import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_demo/chat_screen.dart';
import 'package:socket_demo/cubit/list/chat_list_cubit.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MainApp());
}

IO.Socket socket = IO.io(
    'http://10.0.2.2:3000',
    IO.OptionBuilder().setTransports(['websocket']) // optional
        .build());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatListCubit>(
          create: (context) => ChatListCubit()..getChatList(),
        )
      ],
      child: MaterialApp(
        home: ChatListScreen(),
      ),
    );
  }
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat List")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<ChatListCubit, ChatListState>(
            builder: (context, state) {
              if (state is ChatListLoaded) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ...state.chatList.map((conversation) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  conversation_id: conversation.id,
                                  user_id: conversation.currentUser,
                                  otherUserName: conversation.targetUser.name,
                                ),
                              ),
                            );
                          },
                          title: Text(conversation.targetUser.name),
                          subtitle: Text(conversation.startedAt),
                        );
                      }).toList()
                    ],
                  ),
                );
              } else if (state is ChatListError) {
                return Center(child: Text(state.message));
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
