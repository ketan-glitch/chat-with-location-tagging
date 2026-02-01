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

import '../../domain/usecases/get_users_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUsersUseCase getUsersUseCase;

  HomeBloc(this.getUsersUseCase) : super(HomeInitial()) {
    on<LoadUsers>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      final users = await getUsersUseCase();
      emit(HomeLoaded(users));
    } catch (e) {
      emit(HomeError("Failed to load users"));
    }
  }
}
