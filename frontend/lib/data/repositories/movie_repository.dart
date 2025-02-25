import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:http/http.dart' as http;

class MovieRepository {
  final String baseMovieUrl = ApiConfig.baseMovieUrl;

  //* Fetch All Movies
  Future<List<Map<String, dynamic>>> fetchAllMovies() async {
    try {
      final url = Uri.parse('$baseMovieUrl');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((movie) => _normalizeMovieData(movie)).toList();
      } else {
        throw Exception("Failed to fetch movies");
      }
    } catch (e) {
      throw Exception("Error fetching movies: ${e.toString()}");
    }
  }

  //* Fetch Popular Movies
  Future<List<Map<String, dynamic>>> fetchPopularMovies() async {
    try {
      final url = Uri.parse('$baseMovieUrl/popular');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(response.body);
        return (data['data'] as List)
            .map((movie) => _normalizeMovieData(movie))
            .toList();
      } else {
        throw Exception("Failed to fetch popular movies");
      }
    } catch (e) {
      throw Exception("Error fetching movies: ${e.toString()}");
    }
  }

  //* Search Movies
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    try {
      final url = Uri.parse('$baseMovieUrl/search?q=$query');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((movie) => _normalizeMovieData(movie))
            .toList();
      } else {
        throw Exception("No Movies found");
      }
    } catch (e) {
      throw Exception("Error searching movies: ${e.toString()}");
    }
  }

  //* Fetch Movie Details
  Future<Map<String, dynamic>> fetchMovieDetails(String title) async {
    try {
      final response = await http.get(
        Uri.parse('$baseMovieUrl/fetch/$title'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _normalizeMovieData(data['data']);
      } else {
        throw Exception('Failed to fetch movie details');
      }
    } catch (e) {
      throw Exception("Error fetching movie details: ${e.toString()}");
    }
  }

  //* Filter Movies by Rating
  Future<List<Map<String, dynamic>>> filterMoviesByRating(
      double minRating) async {
    try {
      final url = Uri.parse('$baseMovieUrl/filter/rating');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rating': minRating}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((movie) => _normalizeMovieData(movie))
            .toList();
      } else {
        throw Exception('No movies found');
      }
    } catch (e) {
      throw Exception("Error filtering movies: ${e.toString()}");
    }
  }

  //* Fetch Movies by Category
  Future<List<Map<String, dynamic>>> fetchMoviesByCategory(
      String category) async {
    try {
      final url = Uri.parse('$baseMovieUrl/category/$category');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((movie) => _normalizeMovieData(movie))
            .toList();
      } else {
        throw Exception("Failed to fetch movies for category: $category");
      }
    } catch (e) {
      throw Exception("Error fetching category movies: ${e.toString()}");
    }
  }

  Map<String, dynamic> _normalizeMovieData(Map<String, dynamic> movie) {
    return {
      ...movie,
      //Ensure Genre is always a List<String>
      'Genre': movie['Genre'] is String
          ? (movie['Genre'] as String).split(",").map((e) => e.trim()).toList()
          : (movie['Genre'] ?? []),
      // Convert IMDb Rating to double, default to 0.0 if invalid
      'imdbRating': movie['imdbRating'] is String
          ? double.tryParse(movie['imdbRating'].replaceAll(',', '.')) ?? 0.0
          : (movie['imdbRating'] ?? 0.0),
      // Convert Metascore to int, set to null if "N/A" or invalid
      'Metascore': (movie['Metascore'] is String && movie['Metascore'] != "N/A")
          ? int.tryParse(movie['Metascore']) ?? null
          : null,
      // Ensure Ratings is always a List<Map>
      'Ratings': movie['Ratings'] is List
          ? List<Map<String, dynamic>>.from(movie['Ratings'])
          : [],
      // Ensure Poster is a valid URL or set a placeholder
      'Poster': (movie['Poster'] is String &&
              movie['Poster'].startsWith('http'))
          ? movie['Poster']
          : 'https://via.placeholder.com/300x450.png?text=No+Image+Available',
      // Ensure Language has a default value
      'Language': movie['Language'] ?? "Unknown",
    };
  }
}
