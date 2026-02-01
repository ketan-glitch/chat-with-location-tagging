/*
 * MIT License
 *
 * Copyright (c) 2026 Ketan Kadam
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 *
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../places/domain/usecases/get_place_details_usecase.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/typing_entity.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/detect_active_word_usecase.dart';
import '../../domain/entities/active_word_entity.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetPlaceDetailsUseCase getPlaceDetailsUseCase;

  final List<ChatMessage> _messages = [];

  String _currentText = "";
  int _cursorPosition = 0;

  final DetectActiveWordUseCase detectActiveWordUseCase;
  ActiveWord? _activeWord;

  String? _selectedPlaceId;
  String? _selectedPlaceTitle;
  int? _selectedPlaceStart;
  int? _selectedPlaceEnd;

  ChatBloc(this.getMessagesUseCase, this.sendMessageUseCase, this.detectActiveWordUseCase, this.getPlaceDetailsUseCase) : super(ChatInitial()) {
    on<LoadMessages>(_onLoad);
    on<SendMessage>(_onSend);
    on<MessageTyping>(_onTyping);
    on<PlaceSuggestionSelected>(_onPlaceSelected);
  }

  Future<void> _onLoad(LoadMessages event, Emitter<ChatState> emit) async {
    final messages = await getMessagesUseCase(event.userId);
    _messages
      ..clear()
      ..addAll(messages);

    emit(
      ChatLoaded(
        messages: List.from(_messages),
        typingInfo: TypingInfo(fullText: _currentText, cursorPosition: _cursorPosition),
        activeWord: ActiveWord(word: "", start: 0, end: 0),
      ),
    );
  }

  Future<void> _onSend(SendMessage event, Emitter<ChatState> emit) async {
    if (_currentText.trim().isEmpty) return;
    var messageTxt = _currentText;
    LocationAttachment? attachment;

    if (_selectedPlaceId != null) {
      var start = _selectedPlaceStart;
      var end = _selectedPlaceEnd;
      final location = await getPlaceDetailsUseCase(placeId: _selectedPlaceId!, description: _selectedPlaceTitle!);

      attachment = LocationAttachment(title: location.description, lat: location.lat, lng: location.lng, startIndex: start!, endIndex: end!);
    }

    final msg = sendMessageUseCase(text: messageTxt, location: attachment);

    _messages.add(msg);

    // reset
    _currentText = "";
    _cursorPosition = 0;
    _selectedPlaceId = null;

    emit(
      ChatLoaded(
        messages: List.from(_messages),
        typingInfo: TypingInfo(fullText: "", cursorPosition: 0),
        activeWord: ActiveWord(word: "", start: 0, end: 0),
      ),
    );
  }

  void _onTyping(MessageTyping event, Emitter<ChatState> emit) {
    _selectedPlaceId = null;
    _selectedPlaceTitle = null;
    _selectedPlaceStart = null;
    _selectedPlaceEnd = null;

    _currentText = event.text;
    _cursorPosition = event.cursorPosition;

    _activeWord = detectActiveWordUseCase(_currentText, _cursorPosition);

    emit(
      ChatLoaded(
        messages: List.from(_messages),
        typingInfo: TypingInfo(fullText: _currentText, cursorPosition: _cursorPosition),
        activeWord: _activeWord!,
      ),
    );
  }

  void _onPlaceSelected(PlaceSuggestionSelected event, Emitter<ChatState> emit) {
    _selectedPlaceId = event.placeId;
    _selectedPlaceTitle = event.title;
    _selectedPlaceStart = event.start;
    _selectedPlaceEnd = event.start + event.title.length;

    final before = _currentText.substring(0, event.start);

    final after = _currentText.substring(event.end);

    final newText = "$before${event.title}$after";
    final newCursor = before.length + event.title.length;

    _currentText = newText;
    _cursorPosition = newCursor;

    emit(
      ChatLoaded(
        messages: List.from(_messages),
        typingInfo: TypingInfo(fullText: newText, cursorPosition: newCursor),
        activeWord: ActiveWord(word: "", start: newCursor, end: newCursor),
      ),
    );
  }
}
