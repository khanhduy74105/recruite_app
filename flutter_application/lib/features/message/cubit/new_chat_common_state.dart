import 'package:flutter/cupertino.dart';

@immutable
class NewChatCommonState {}

final class NewChatInitial extends NewChatCommonState {}

final class NewChatLoading extends NewChatCommonState {}

final class NewChatError extends NewChatCommonState {
  final String message;

  NewChatError({required this.message});
}