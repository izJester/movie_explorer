import 'package:flutter/material.dart';
import 'package:movie_explorer/Entities/movie.dart';
import 'package:movie_explorer/Utils/movie_utils.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: movie.fullBackdropPath.isNotEmpty
                  ? Image.network(
                      movie.fullBackdropPath,
                      fit: BoxFit.cover,
                    )
                  : Image.asset('images/default-movie.png'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(movie.title,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(movie.voteAverage.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(' (${movie.voteCount})',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(movie.releaseDate!),

                  const SizedBox(height: 8),

                  // Fecha y género
                  Wrap(
                    spacing: 8,
                    children: [
                      ...movie.genreIds.map((genre) => 
                          Chip(
                            label: Text(genre.genreName),
                            backgroundColor: Colors.grey[200],
                          )),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sinopsis
                  Text('Sinopsis',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(movie.overview,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
