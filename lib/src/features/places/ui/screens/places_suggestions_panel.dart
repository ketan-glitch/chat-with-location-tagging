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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../chat/ui/blocs/chat_bloc.dart';
import '../../../chat/ui/blocs/chat_event.dart';
import '../../../chat/ui/blocs/chat_state.dart';
import '../blocs/places_bloc.dart';
import '../blocs/places_event.dart';
import '../blocs/places_state.dart';

class PlacesSuggestionsPanel extends StatelessWidget {
  const PlacesSuggestionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        if (state is PlacesLoaded) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListView.builder(
              itemCount: state.suggestions.length,
              itemBuilder: (context, index) {
                final item = state.suggestions[index];

                return ListTile(
                  title: Text(item.description),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    final chatState = context.read<ChatBloc>().state;

                    if (chatState is ChatLoaded) {
                      context.read<ChatBloc>().add(
                        PlaceSuggestionSelected(
                          placeId: item.placeId,
                          title: item.description,
                          start: chatState.activeWord.start,
                          end: chatState.activeWord.end,
                        ),
                      );
                    }

                    context.read<PlacesBloc>().add(ClearPlaces());
                  },
                );
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
