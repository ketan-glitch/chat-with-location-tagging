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

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_place_suggestions_usecase.dart';
import 'places_event.dart';
import 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final GetPlaceSuggestionsUseCase getSuggestionsUseCase;

  Timer? _debounce;

  PlacesBloc(this.getSuggestionsUseCase) : super(PlacesInitial()) {
    on<PlacesQueryChanged>(_onQueryChanged);
    on<ClearPlaces>(_onClear);
  }

  Future<void> _onQueryChanged(PlacesQueryChanged event, Emitter<PlacesState> emit) async {
    _debounce?.cancel();

    final completer = Completer<void>();
    _debounce = Timer(const Duration(milliseconds: 350), () => completer.complete());

    await completer.future;

    if (emit.isDone) return;

    if (event.query.trim().isEmpty || event.query.trim().length < 2) {
      emit(PlacesEmpty());
      return;
    }

    emit(PlacesLoading());

    try {
      final results = await getSuggestionsUseCase(event.query);

      if (emit.isDone) return;

      emit(results.isEmpty ? PlacesEmpty() : PlacesLoaded(results));
    } catch (_) {
      if (emit.isDone) return;
      emit(PlacesEmpty());
    }
  }

  void _onClear(ClearPlaces event, Emitter<PlacesState> emit) {
    _debounce?.cancel();
    emit(PlacesEmpty());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
