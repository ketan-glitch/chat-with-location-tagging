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

import '../entities/active_word_entity.dart';

class DetectActiveWordUseCase {
  ActiveWord call(String text, int cursorPosition) {
    if (text.isEmpty || cursorPosition < 0) {
      return ActiveWord(word: "", start: 0, end: 0);
    }


    ///Find the active word
    int start = cursorPosition;
    int end = cursorPosition;
    while (start > 0 && text[start - 1] != ' ') {
      start--;
    }
    while (end < text.length && text[end] != ' ') {
      end++;
    }

    final word = text.substring(start, end);

    return ActiveWord(word: word, start: start, end: end);
  }
}
