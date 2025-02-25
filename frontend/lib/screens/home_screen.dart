import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/blocs/movie_bloc.dart';
import 'package:frontend/widgets/bars/custom_app_bar.dart';
import 'package:frontend/widgets/cards/movie_card.dart';
import 'package:frontend/widgets/dialogs/custom_snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  void _fetchMovies() {
    final movieBloc = context.read<MovieBloc>();
    debugPrint("Fetching Movies for all categories...");

    //* Fetch each category separately
    const categories = ["popular", "high_rated", "action", "comedy", "drama"];
    for (var category in categories) {
      debugPrint("🔄 Fetching category: $category");
      movieBloc.add(FetchMoviesByCategory(category));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess && state.message == "Logout Successful") {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Discover",
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => Navigator.pushNamed(context, '/search'),
            ),
            IconButton(
              icon: const Icon(Icons.person_rounded),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => Navigator.pushNamed(context, '/filter'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logoutUser(context),
            ),
          ],
        ),
        body: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            debugPrint("🎬 Bloc State: $state");

            if (state is MovieLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MovieError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Failed to load movies. Please try again."),
                    TextButton(
                      onPressed: _fetchMovies,
                      child: const Text("🔄 Retry"),
                    ),
                  ],
                ),
              );
            }

            if (state is MoviesByCategoryListLoaded) {
              debugPrint("Movies Loaded: ${state.categorizedMovies.keys}");

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildFeaturedMovie(state),
                    for (var category in [
                      "popular",
                      "high_rated",
                      "action",
                      "comedy",
                      "drama"
                    ])
                      _buildMovieCategory(
                          _getCategoryTitle(category), category, state),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }

            return const Center(child: Text("🎬 No movies available"));
          },
        ),
      ),
    );
  }

  void _logoutUser(BuildContext context) {
    context.read<AuthBloc>().add(LogoutRequested());
    CustomSnackbar.show(context: context, message: "Logged Out Successfully");
  }

  Widget _buildFeaturedMovie(MoviesByCategoryListLoaded state) {
    final popularMovies = state.categorizedMovies["popular"] ?? [];
    if (popularMovies.isNotEmpty) {
      final movie = popularMovies.first; // Pick the first movie as a feature
      return GestureDetector(
        onTap: () => _navigateToMovieDetails(movie),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  movie['Poster'] ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  movie['Title'] ?? '',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMovieCategory(
      String title, String category, MoviesByCategoryListLoaded state) {
    final movies = state.categorizedMovies[category] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.displaySmall),
        ),
        SizedBox(
          height: 230,
          child: movies.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    return MovieCard(movieData: movies[index]);
                  },
                )
              : const Center(child: Text("📭 No movies found")),
        ),
      ],
    );
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case "popular":
        return "🔥 Popular Movies";
      case "high_rated":
        return "⭐ High Rated";
      case "action":
        return "🎬 Action Movies";
      case "comedy":
        return "😂 Comedy Films";
      case "drama":
        return "🎭 Drama Movies";
      default:
        return category;
    }
  }

  void _navigateToMovieDetails(Map<String, dynamic> movie) {
    Navigator.pushNamed(context, '/movieDetails', arguments: movie);
  }
}
