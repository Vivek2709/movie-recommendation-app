import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/blocs/movie_bloc.dart';
import 'package:frontend/blocs/watchlist_bloc.dart';
import 'package:frontend/widgets/bars/custom_app_bar.dart';
import 'package:frontend/widgets/cards/movie_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late String uid;
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      uid = authState.uid;
      _fetchWatchlist();
    } else {
      uid = "";
    }
  }

  void _fetchWatchlist() {
    context.read<WatchlistBloc>().add(LoadWatchlist(uid));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: "My Watchlist"),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, watchlistState) {
          if (watchlistState is WatchlistLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (watchlistState is WatchlistError) {
            return Center(
              child: Text(
                "Error loading watchlist!",
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }
          if (watchlistState is WatchlistLoaded) {
            final watchlistMovies = watchlistState.watchlist;
            if (watchlistMovies.isEmpty) {
              return const Center(
                child: Text(
                  "📭 Your watchlist is empty!",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            return BlocBuilder<MovieBloc, MovieState>(
              builder: (context, movieState) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: watchlistMovies.length,
                    itemBuilder: (context, index) {
                      final movieId = watchlistMovies[index];
                      context.read<MovieBloc>().add(FetchMovieByTitle(movieId));
                      if (movieState is MovieLoaded &&
                          movieState.movieData['imdbID'] == movieId) {
                        final movie = movieState.movieData;
                        return MovieCard(movieData: movie);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Something went wrong!"));
        },
      ),
    );
  }
}
