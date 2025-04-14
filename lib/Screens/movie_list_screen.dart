import 'package:flutter/material.dart';
import 'package:movie_explorer/Entities/movie.dart';
import 'package:movie_explorer/Providers/movie_provider.dart';
import 'package:movie_explorer/Widgets/movie_item.dart';
import 'package:provider/provider.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  bool _initialLoad = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialMovies();
    });
  }

  Future<void> _loadInitialMovies() async {
    try {
      await context.read<MovieProvider>().fetchMovies();
    } finally {
      if (mounted) {
        setState(() => _initialLoad = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<MovieProvider>().loadMoreMovies();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
  }

  List<Movie> _filterMovies(List<Movie> movies, String query) {
    if (query.isEmpty) return movies;
    return movies
        .where((movie) =>
            movie.title.toLowerCase().contains(query.toLowerCase()) ||
            movie.originalTitle.toLowerCase().contains(query.toLowerCase()) ||
            movie.overview.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      await context.read<MovieProvider>().fetchMovies();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final filteredMovies =
        _filterMovies(movieProvider.movies, _searchController.text);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? const Text('Buscar películas')
            : const Text('Movie Explorer'),
      ),
      body: _initialLoad
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    leading: const Icon(Icons.search),
                    hintText: 'Buscar películas...',
                  ),
                ),
                Expanded(
                  child: _buildMovieList(movieProvider, filteredMovies),
                ),
              ],
            ),
    );
  }

  Widget _buildMovieList(MovieProvider movieProvider, List<Movie> movies) {
    // Mostrar lista vacía solo si no está refrescando y realmente no hay películas
    if (movies.isEmpty && !_isRefreshing && !movieProvider.isLoading) {
      return const Center(child: Text('No se encontraron películas'));
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: movies.length + (movieProvider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == movies.length) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ));
          }
          return MovieItem(movie: movies[index]);
        },
      ),
    );
  }

}
