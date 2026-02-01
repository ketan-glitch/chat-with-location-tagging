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

import '../../domain/entities/place_location_entity.dart';
import '../../domain/entities/place_suggestion_entity.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/remote_data_sources/places_remote_data_source.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource dataSource;

  PlacesRepositoryImpl(this.dataSource);

  @override
  Future<List<PlaceSuggestion>> getSuggestions(String query) {
    return dataSource.getSuggestions(query);
  }

  @override
  Future<PlaceLocation> getPlaceDetails({required String placeId, required String description}) {
    return dataSource.getPlaceDetails(placeId: placeId, description: description);
  }
}
