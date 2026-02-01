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

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../domain/entities/place_location_entity.dart';
import '../../../domain/entities/place_suggestion_entity.dart';

class PlacesRemoteDataSource {
  final String apiKey;

  PlacesRemoteDataSource(this.apiKey);

  Future<List<PlaceSuggestion>> getSuggestions(String query) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$query"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Places API error");
    }

    final body = json.decode(response.body);

    final predictions = body["predictions"] as List;

    return predictions.map((e) => PlaceSuggestion(placeId: e["place_id"], description: e["description"])).toList();
  }

  Future<PlaceLocation> getPlaceDetails({required String placeId, required String description}) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&fields=geometry"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Place details error");
    }

    final body = json.decode(response.body);

    final location = body["result"]["geometry"]["location"];

    return PlaceLocation(description: description, lat: location["lat"], lng: location["lng"]);
  }
}
