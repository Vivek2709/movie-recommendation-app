import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:http/http.dart' as http;

class WatchlistRepository {
  final String baseUrl = ApiConfig.baseWatchListUrl;

  //* Fetch Watchlist
  Future<List<String>> fetchWatchlist(String uid) async {
    try {
      final url = Uri.parse('$baseUrl/$uid');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['data'] ?? []);
      } else {
        throw Exception("Failed to fetch watchlist");
      }
    } catch (e) {
      debugPrint("Error Fetching Watchlist: ${e.toString()}");
      throw Exception("Error Fetching Watchlist");
    }
  }

  //* Add To Watchlist
  Future<bool> addToWatchlist(String uid, String movieId) async {
    try {
      final url = Uri.parse('$baseUrl/$uid');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'movieId': movieId}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to add to watchlist");
      }
    } catch (e) {
      debugPrint("Error adding to watchlist: ${e.toString()}");
      throw Exception("Error adding to watchlist");
    }
  }

  //* Remove From Watchlist
  Future<bool> removeFromWatchlist(String uid, String movieId) async {
    try {
      final url = Uri.parse('$baseUrl/$uid');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'movieId': movieId}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to remove from watchlist");
      }
    } catch (e) {
      debugPrint("Error removing from watchlist: ${e.toString()}");
      throw Exception("Error removing from watchlist");
    }
  }
}
