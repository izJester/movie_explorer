import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_explorer/Entities/movie.dart';
import 'package:movie_explorer/Providers/movie_provider.dart';
import 'package:movie_explorer/Screens/movie_details_screen.dart';
import 'package:movie_explorer/Screens/movie_list_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider())
      ],
      child: MaterialApp(
        title: 'Movie Explorer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const MovieListScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/details') {
            final movie = settings.arguments as Movie;
            return MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(movie: movie),
            );
          }
          return null;
        },
      ),
    );
  }
}

