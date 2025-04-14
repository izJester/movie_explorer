import 'package:flutter/material.dart';
import 'package:movie_explorer/Entities/movie.dart';

class MovieItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  
  const MovieItem({
    super.key,
    required this.movie,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/details',
            arguments: movie,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: movie.fullPosterPath.isNotEmpty ? NetworkImage(movie.fullPosterPath) : const AssetImage('images/default-movie.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(movie.voteAverage.toStringAsFixed(1)),
                        const SizedBox(width: 12),
                        Text(movie.releaseDate ?? 'Fecha desconocida'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
