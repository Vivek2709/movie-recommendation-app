import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/config/api_config.dart';

class TrailerRepository {
  final String _youtubeApiKey = ApiConfig.youtubeApiKey;
  final String _searchUrl = "https://www.googleapis.com/youtube/v3/search";

  //* Fetch Trailer from YouTube API (with caching)
  Future<String?> fetchTrailer(String movieTitle) async {
    final prefs =
        await SharedPreferences.getInstance(); // 🔹 Get shared prefs instance
    final cacheKey = "trailer_$movieTitle"; // 🔹 Unique cache key

    //*Checking Cache First
    final cachedUrl = prefs.getString(cacheKey);
    if (cachedUrl != null) {
      debugPrint("🎥 Cached Trailer Found: $cachedUrl");
      return cachedUrl; // 🔹 Return cached trailer
    }

    //*If Not Cached, Fetch from YouTube API
    try {
      final query = "$movieTitle Official Trailer";
      final url = Uri.parse(
          "$_searchUrl?part=snippet&q=$query&type=video&key=$_youtubeApiKey");

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;

        if (items.isNotEmpty) {
          final videoId = items[0]['id']['videoId'];
          final trailerUrl = "https://www.youtube.com/watch?v=$videoId";

          //*Store in Cache for Future Use
          await prefs.setString(cacheKey, trailerUrl);
          debugPrint("Trailer Cached: $trailerUrl");

          return trailerUrl;
        }
      }
    } catch (e) {
      debugPrint("Error fetching trailer: ${e.toString()}");
    }

    return null; // Return null if no trailer found
  }
}
