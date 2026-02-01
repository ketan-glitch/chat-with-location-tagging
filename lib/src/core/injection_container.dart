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

import 'package:get_it/get_it.dart';

import '../features/auth/data/datasources/remote_data_sources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/ui/blocs/auth_bloc.dart';
import '../features/chat/data/datasources/remote_data_sources/chat_remote_data_source.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/detect_active_word_usecase.dart';
import '../features/chat/domain/usecases/get_messages_usecase.dart';
import '../features/chat/domain/usecases/send_message_usecase.dart';
import '../features/chat/ui/blocs/chat_bloc.dart';
import '../features/home/data/datasources/remote_data_sources/home_remote_data_source.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/domain/usecases/get_users_usecase.dart';
import '../features/home/ui/blocs/home_bloc.dart';
import '../features/places/data/datasources/remote_data_sources/places_remote_data_source.dart';
import '../features/places/data/repositories/places_repository_impl.dart';
import '../features/places/domain/repositories/places_repository.dart';
import '../features/places/domain/usecases/get_place_details_usecase.dart';
import '../features/places/domain/usecases/get_place_suggestions_usecase.dart';
import '../features/places/ui/blocs/places_bloc.dart';
import 'config/env.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // AUTH
  sl.registerLazySingleton(() => AuthRemoteDataSource());
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), registerUseCase: sl()));

  // HOME
  sl.registerLazySingleton(() => HomeDataSource());
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerFactory(() => HomeBloc(sl()));

  // CHAT
  sl.registerLazySingleton(() => ChatDataSource());
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase());
  sl.registerLazySingleton(() => DetectActiveWordUseCase());

  sl.registerFactory(
    () => ChatBloc(
      sl(), // getMessages
      sl(), // sendMessage
      sl(), // detectWord
      sl(), // getPlaceDetails
    ),
  );

  // PLACES
  sl.registerLazySingleton(() => PlacesRemoteDataSource(googlePlacesApiKey));

  sl.registerLazySingleton<PlacesRepository>(() => PlacesRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetPlaceSuggestionsUseCase(sl()));
  sl.registerLazySingleton(() => GetPlaceDetailsUseCase(sl()));
  sl.registerFactory(() => PlacesBloc(sl()));
}
