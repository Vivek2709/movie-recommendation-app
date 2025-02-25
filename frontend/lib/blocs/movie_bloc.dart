import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/repositories/movie_repository.dart';

//* Events
abstract class MovieEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMovieByTitle extends MovieEvent {
  final String title;
  FetchMovieByTitle(this.title);
  @override
  List<Object?> get props => [title];
}

class FetchAllMovies extends MovieEvent {}

class FetchPopularMovies extends MovieEvent {}

class SearchMovies extends MovieEvent {
  final String query;
  SearchMovies(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterMoviesByRating extends MovieEvent {
  final double minRating;
  FilterMoviesByRating(this.minRating);
  @override
  List<Object?> get props => [minRating];
}

class FetchMoviesByCategory extends MovieEvent {
  final String category;
  FetchMoviesByCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class FilterMoviesByGenre extends MovieEvent {
  final String genre;
  FilterMoviesByGenre(this.genre);
  @override
  List<Object?> get props => [genre];
}

//* States
abstract class MovieState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final Map<String, dynamic> movieData;
  MovieLoaded(this.movieData);
  @override
  List<Object> get props => [movieData];
}

class MoviesByCategoryListLoaded extends MovieState {
  final Map<String, List<Map<String, dynamic>>> categorizedMovies;
  final String selectedGenre;
  MoviesByCategoryListLoaded(this.categorizedMovies,
      {this.selectedGenre = "All"});
  @override
  List<Object?> get props => [
        categorizedMovies,
      ];
}

class MoviesListLoaded extends MovieState {
  final List<Map<String, dynamic>> movies;
  MoviesListLoaded(this.movies);
  @override
  List<Object?> get props => [movies];
}

class MovieError extends MovieState {
  final String message;
  MovieError(this.message);
  @override
  List<Object?> get props => [message];
}

//* Bloc Implementation
class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository movieRepository;
  MovieBloc({required this.movieRepository}) : super(MovieInitial()) {
    //* Fetch a Movie by Title
    on<FetchMovieByTitle>((event, emit) async {
      emit(MovieLoading());
      try {
        final movieData = await movieRepository.fetchMovieDetails(event.title);
        emit(MovieLoaded(movieData));
      } catch (e) {
        emit(MovieError('Error fetching: ${e.toString()}'));
      }
    });

    //* Fetch All Movies
    on<FetchAllMovies>((event, emit) async {
      emit(MovieLoading());
      try {
        final movieList = await movieRepository.fetchAllMovies();
        emit(MoviesListLoaded(movieList));
      } catch (e) {
        emit(MovieError("Error fetching movies: ${e.toString()}"));
      }
    });

    //* Fetch Popular Movies
    on<FetchPopularMovies>((event, emit) async {
      emit(MovieLoading());
      try {
        final popularMovies = await movieRepository.fetchPopularMovies();
        emit(MoviesListLoaded(popularMovies));
      } catch (e) {
        emit(MovieError("Error fetching popular movies: ${e.toString()}"));
      }
    });

    //* Search Movies
    on<SearchMovies>((event, emit) async {
      emit(MovieLoading());
      try {
        final searchResults = await movieRepository.searchMovies(event.query);
        emit(MoviesListLoaded(searchResults));
      } catch (e) {
        emit(MovieError("Error searching movies: ${e.toString()}"));
      }
    });

    //* Filter Movies by Rating
    on<FilterMoviesByRating>((event, emit) async {
      emit(MovieLoading());
      try {
        final filteredMovies =
            await movieRepository.filterMoviesByRating(event.minRating);
        emit(MoviesListLoaded(filteredMovies));
      } catch (e) {
        emit(MovieError("Error filtering movies: ${e.toString()}"));
      }
    });

    //* Fetch Movies by Categories (Batch Fetching)
    on<FetchMoviesByCategory>((event, emit) async {
      try {
        debugPrint("🔄 Fetching movies for category: ${event.category}");
        final movies =
            await movieRepository.fetchMoviesByCategory(event.category);
        debugPrint(
            "Fetched ${movies.length} movies for category: ${event.category}");

        // Re-read the current state right before merging to ensure we have the latest data
        Map<String, List<Map<String, dynamic>>> updatedCategories = {};
        if (state is MoviesByCategoryListLoaded) {
          updatedCategories =
              Map.from((state as MoviesByCategoryListLoaded).categorizedMovies);
        }

        // Merge the new category data
        updatedCategories[event.category] = movies;
        debugPrint("Updated categories: ${updatedCategories.keys.toList()}");

        emit(MoviesByCategoryListLoaded(Map.from(updatedCategories)));
      } catch (e) {
        emit(MovieError("Error Fetching movies: ${e.toString()}"));
      }
    });

    on<FilterMoviesByGenre>((event, emit) async {
      if (state is MoviesByCategoryListLoaded) {
        final currentState = state as MoviesByCategoryListLoaded;
        final allMovies = currentState.categorizedMovies;
        if (event.genre == "All") {
          emit(MoviesByCategoryListLoaded(allMovies, selectedGenre: "All"));
        } else {
          //* Filtering Movies by genre
          Map<String, List<Map<String, dynamic>>> filteredMovies = {};
          allMovies.forEach((category, movies) {
            filteredMovies[category] = movies
                .where((movie) =>
                    movie['Genre'] != null &&
                    (movie['Genre'] as List).contains(event.genre))
                .toList();
          });
          emit(MoviesByCategoryListLoaded(filteredMovies,
              selectedGenre: event.genre));
        }
      }
    });
  }
}
