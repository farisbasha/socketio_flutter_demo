import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_demo/models/conversation.dart';

part 'chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit() : super(ChatListInitial());

  void getChatList() async {
    final userId = Platform.isAndroid ? 2 : 1;
    final url = Platform.isAndroid
        ? "http://10.0.2.2:8002/api/chat/conversation/${userId}"
        : "http://localhost:8002/api/chat/conversation/${userId}";
    emit(ChatListLoading());
    try {
      final resp = await Dio().get(url);
      final List<Conversation> chatList = [];
      resp.data.forEach((conversation) {
        chatList.add(Conversation.fromJson(conversation));
      });
      emit(ChatListLoaded(chatList));
    } catch (e) {
      print(e.toString());
      emit(ChatListError(e.toString()));
    }
  }
}
