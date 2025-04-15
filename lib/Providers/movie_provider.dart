import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:movie_explorer/Entities/movie.dart';

class MovieProvider extends ChangeNotifier {
  List<Movie> movies = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  bool isOffline = false;
  
  static Database? _database;

  // Método para obtener la API key desde las variables de entorno
  String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  
  // Método para obtener la URL base desde las variables de entorno
  String get _baseUrl => dotenv.env['TMDB_BASE_URL'] ?? 'https://api.themoviedb.org/3';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'movies.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE movies(
            id INTEGER PRIMARY KEY,
            adult INTEGER,
            backdrop_path TEXT,
            genre_ids TEXT,
            original_language TEXT,
            original_title TEXT,
            overview TEXT,
            popularity REAL,
            poster_path TEXT,
            release_date TEXT,
            title TEXT,
            video INTEGER,
            vote_average REAL,
            vote_count INTEGER,
            page INTEGER
          )
        ''');
      },
    );
  }

  Future<void> fetchMovies({bool loadMore = false}) async {
    if (isLoading) return;
    
    // Verificar conexión a internet
    final connectivityResult = await Connectivity().checkConnectivity();
    isOffline = connectivityResult == ConnectivityResult.none;
    
    if (!loadMore) {
      currentPage = 1;
      movies.clear();
    }

    isLoading = true;
    notifyListeners();

    try {
      if (isOffline) {
        // Cargar desde SQLite
        await _loadMoviesFromDatabase();
      } else {
        // Cargar desde API
        await _fetchMoviesFromApi(loadMore: loadMore);
      }
    } catch (error) {
      // Si falla la API, intentar cargar desde SQLite
      if (!isOffline) {
        try {
          await _loadMoviesFromDatabase();
          isOffline = true;
        } catch (dbError) {
          throw Exception('Failed to load movies: $error (API) and $dbError (DB)');
        }
      } else {
        throw Exception('Failed to load movies: $error');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchMoviesFromApi({bool loadMore = false}) async {
    final url = Uri.parse(
      '$_baseUrl/movie/now_playing?language=en-US&page=$currentPage',
    );

     final response = await http.get(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $_apiKey', // Usamos la variable de entorno aquí
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'] ?? [];
      
      final newMovies = results.map((item) => Movie.fromJson(item)).toList();
      
      if (loadMore) {
        movies.addAll(newMovies);
      } else {
        movies = newMovies;
      }

      currentPage = data['page'] ?? currentPage;
      totalPages = data['total_pages'] ?? totalPages;
      
      // Guardar en SQLite
      await _saveMoviesToDatabase(newMovies, currentPage);
    } else {
      throw Exception('Failed to load movies: ${response.statusCode}');
    }
  }

  Future<void> _saveMoviesToDatabase(List<Movie> moviesToSave, int page) async {
    final db = await database;
    
    // Eliminar películas antiguas de la misma página
    await db.delete('movies', where: 'page = ?', whereArgs: [page]);
    
    // Insertar nuevas películas
    for (final movie in moviesToSave) {
      await db.insert('movies', {
        'id': movie.id,
        'adult': movie.adult ? 1 : 0,
        'backdrop_path': movie.backdropPath,
        'genre_ids': movie.genreIds.join(','), // Almacenar lista como string separado por comas
        'original_language': movie.originalLanguage,
        'original_title': movie.originalTitle,
        'overview': movie.overview,
        'popularity': movie.popularity,
        'poster_path': movie.posterPath,
        'release_date': movie.releaseDate,
        'title': movie.title,
        'video': movie.video ? 1 : 0,
        'vote_average': movie.voteAverage,
        'vote_count': movie.voteCount,
        'page': page,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _loadMoviesFromDatabase() async {
    final db = await database;
    
    // Obtener todas las películas ordenadas por página
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      orderBy: 'page ASC',
    );
    
    if (maps.isNotEmpty) {
      movies = List.generate(maps.length, (i) {
        return Movie(
          id: maps[i]['id'],
          adult: maps[i]['adult'] == 1,
          backdropPath: maps[i]['backdrop_path'],
          genreIds: (maps[i]['genre_ids'] as String?)?.split(',').map(int.parse).toList() ?? [],
          originalLanguage: maps[i]['original_language'] ?? '',
          originalTitle: maps[i]['original_title'] ?? '',
          overview: maps[i]['overview'] ?? '',
          popularity: maps[i]['popularity'] ?? 0.0,
          posterPath: maps[i]['poster_path'],
          releaseDate: maps[i]['release_date'],
          title: maps[i]['title'] ?? '',
          video: maps[i]['video'] == 1,
          voteAverage: maps[i]['vote_average'] ?? 0.0,
          voteCount: maps[i]['vote_count'] ?? 0,
        );
      });
      
      // Establecer la última página cargada
      final lastPage = maps.last['page'] as int?;
      currentPage = lastPage ?? 1;
      
      // En modo offline, no sabemos el total de páginas
      totalPages = currentPage;
    } else {
      throw Exception('No movies found in database');
    }
  }

  Future<void> loadMoreMovies() async {
    if (currentPage < totalPages || isOffline) {
      currentPage++;
      await fetchMovies(loadMore: true);
    }
  }
}