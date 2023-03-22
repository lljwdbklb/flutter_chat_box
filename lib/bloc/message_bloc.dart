import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_chatgpt/repository/message.dart';
import 'package:flutter_chatgpt/utils/log.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc() : super(MessageInitial()) {
    on<SendMessageEvent>((event, emit) async {
      emit(const MessageSending());
      try {
        await MessageRepository().postMessage(event.message);
        log("当前会话ID是11111   ${event.message.conversationId}");
        final messages = await ConversationRepository()
            .getMessagesByConversationUUid(event.message.conversationId);
        emit(MessagesLoaded(messages));
      } catch (e) {
        emit(MessageError(e.toString()));
      }
    });

    on<DeleteMessageEvent>((event, emit) async {
      try {
        await ConversationRepository().deleteMessage(event.message.id!);
        final messages = await ConversationRepository()
            .getMessagesByConversationUUid(event.message.conversationId);
        emit(MessagesLoaded(messages));
      } catch (e) {
        emit(MessageError(e.toString()));
      }
    });

    on<LoadAllMessagesEvent>((event, emit) async {
      log("当前会话ID是22222  ${event.conversationUUid}");
      emit(const MessageLoading());
      try {
        final messages = await ConversationRepository()
            .getMessagesByConversationUUid(event.conversationUUid);
        emit(MessagesLoaded(messages));
      } catch (e) {
        emit(MessageError(e.toString()));
      }
    });
  }
}
