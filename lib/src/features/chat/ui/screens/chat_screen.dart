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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../home/domain/entities/chat_user_entity.dart';
import '../../../places/ui/blocs/places_bloc.dart';
import '../../../places/ui/blocs/places_event.dart';
import '../../../places/ui/screens/places_suggestions_panel.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../blocs/chat_bloc.dart';
import '../blocs/chat_event.dart';
import '../blocs/chat_state.dart';

class ChatPage extends StatefulWidget {
  final ChatUser user;

  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  bool _updatingFromBloc = false;

  @override
  void initState() {
    super.initState();

    context.read<ChatBloc>().add(LoadMessages(widget.user.id));

    _controller.addListener(() {
      if (_updatingFromBloc) return;

      final selection = _controller.selection;

      if (selection.baseOffset < 0) return;

      // ✅ Prevent pointless empty → empty spam
      if (_controller.text.isEmpty) {
        context.read<ChatBloc>().add(MessageTyping(text: "", cursorPosition: 0));
        return;
      }

      context.read<ChatBloc>().add(MessageTyping(text: _controller.text, cursorPosition: selection.baseOffset));
    });
  }

  void _send() {
    context.read<ChatBloc>().add(SendMessage(_controller.text));
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.name)),
      body: MultiBlocListener(
        listeners: [
          // --------------------------------------------------
          // 1) APPLY TYPING STATE → CONTROLLER
          // --------------------------------------------------
          BlocListener<ChatBloc, ChatState>(
            listenWhen: (prev, curr) => curr is ChatLoaded && prev is ChatLoaded && prev.typingInfo.fullText != curr.typingInfo.fullText,
            listener: (context, state) {
              if (state is ChatLoaded) {
                // prevent overwrite loop
                if (_controller.text == state.typingInfo.fullText) {
                  return;
                }

                _updatingFromBloc = true;

                _controller.value = TextEditingValue(
                  text: state.typingInfo.fullText,
                  selection: TextSelection.collapsed(offset: state.typingInfo.cursorPosition),
                );

                _updatingFromBloc = false;
              }
            },
          ),

          // --------------------------------------------------
          // 2) CHAT → PLACES MEDIATOR
          // --------------------------------------------------
          BlocListener<ChatBloc, ChatState>(
            listenWhen: (_, curr) => curr is ChatLoaded,
            listener: (context, state) {
              if (state is ChatLoaded) {
                final word = state.activeWord.word;

                // Only trigger when cursor at end of word
                if (word.isNotEmpty && state.typingInfo.cursorPosition == state.activeWord.end) {
                  context.read<PlacesBloc>().add(PlacesQueryChanged(word));
                } else {
                  context.read<PlacesBloc>().add(ClearPlaces());
                }
              }
            },
          ),
        ],
        child: Column(
          children: [
            Expanded(child: _MessagesList()),
            const PlacesSuggestionsPanel(),
            _InputBar(controller: _controller, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final msg = state.messages[index];
              return _MessageBubble(message: msg);
            },
          );
        }

        return const Center(child: Text("Start chatting"));
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bg = message.isMe ? Colors.blueAccent : Colors.grey.shade300;
    final textColor = message.isMe ? Colors.white : Colors.black;

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRichText(textColor),
            if (message.location != null) ...[const SizedBox(height: 8), _MapPreview(location: message.location!)],
          ],
        ),
      ),
    );
  }

  Widget _buildRichText(Color textColor) {
    final loc = message.location;
    log(message.text);

    if (loc == null) {
      return Text(message.text, style: TextStyle(color: textColor));
    }
    if (loc.startIndex < 0 || loc.endIndex > message.text.length) {
      return Text(message.text, style: TextStyle(color: textColor));
    }

    final before = message.text.substring(0, loc.startIndex);
    final place = message.text.substring(loc.startIndex, loc.endIndex);
    final after = message.text.substring(loc.endIndex);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: before,
            style: TextStyle(color: textColor),
          ),
          TextSpan(
            text: '📍$place',
            style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: after,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  final LocationAttachment location;

  const _MapPreview({required this.location});

  @override
  Widget build(BuildContext context) {
    final position = CameraPosition(target: LatLng(location.lat, location.lng), zoom: 14);

    return SizedBox(
      height: 160,
      width: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: position,
          markers: {Marker(markerId: const MarkerId("place"), position: LatLng(location.lat, location.lng))},
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          liteModeEnabled: true, // Android performance boost
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Type message...", contentPadding: EdgeInsets.all(12)),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: onSend),
        ],
      ),
    );
  }
}
