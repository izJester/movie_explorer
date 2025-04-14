import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:movie_explorer/Entities/movie.dart';

class MovieProvider extends ChangeNotifier {
  List<Movie> movies = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;

  Future<void> fetchMovies({bool loadMore = false}) async {
    if (isLoading) return;
    
    if (!loadMore) {
      currentPage = 1;
      movies.clear();
    }

    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://api.themoviedb.org/3/movie/now_playing?language=en-US&page=$currentPage',
      );

      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3NDZkMmFjN2NmYmIxOGFiNWU1YjFjOTBmYWM3Y2FhMiIsIm5iZiI6MTc0NDUxOTUyNS44OTIsInN1YiI6IjY3ZmI0MTY1ZDRjNDQ0YTFjYzlhMzFlZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.nM_wxYvMy9xrKkTmcJdpvN8TSjtIaoJ_h2cLFpzWIHc',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        
        if (loadMore) {
          movies.addAll(results.map((item) => Movie.fromJson(item)).toList());
        } else {
          movies = results.map((item) => Movie.fromJson(item)).toList();
        }

        currentPage = data['page'] ?? currentPage;
        totalPages = data['total_pages'] ?? totalPages;
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to load movies: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMovies() async {
    if (currentPage < totalPages) {
      currentPage++;
      await fetchMovies(loadMore: true);
    }
  }
}