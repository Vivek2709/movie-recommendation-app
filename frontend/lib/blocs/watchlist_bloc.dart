import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/repositories/watchlist_repository.dart';

//* Events
abstract class WatchlistEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWatchlist extends WatchlistEvent {
  final String uid;
  LoadWatchlist(this.uid);

  @override
  List<Object?> get props => [uid];
}

class AddToWatchlist extends WatchlistEvent {
  final String uid;
  final String movieId;
  AddToWatchlist(this.uid, this.movieId);

  @override
  List<Object?> get props => [uid, movieId];
}

class RemoveFromWatchlist extends WatchlistEvent {
  final String uid;
  final String movieId;
  RemoveFromWatchlist(this.uid, this.movieId);

  @override
  List<Object?> get props => [uid, movieId];
}

//* States
abstract class WatchlistState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<String> watchlist;
  WatchlistLoaded(this.watchlist);

  @override
  List<Object?> get props => [watchlist];
}

class WatchlistError extends WatchlistState {
  final String message;
  WatchlistError(this.message);

  @override
  List<Object?> get props => [message];
}

//* Bloc
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository watchlistRepository;

  WatchlistBloc({required this.watchlistRepository})
      : super(WatchlistInitial()) {
    //* Load Watchlist
    on<LoadWatchlist>((event, emit) async {
      emit(WatchlistLoading());
      try {
        final watchlist = await watchlistRepository.fetchWatchlist(event.uid);
        emit(WatchlistLoaded(watchlist));
      } catch (e) {
        emit(WatchlistError("Failed to load watchlist: ${e.toString()}"));
      }
    });

    //* Add to Watchlist
    on<AddToWatchlist>((event, emit) async {
      if (state is WatchlistLoaded) {
        final currentList = (state as WatchlistLoaded).watchlist;

        if (!currentList.contains(event.movieId)) {
          final updatedList = List<String>.from(currentList)
            ..add(event.movieId);
          emit(WatchlistLoaded(updatedList));

          try {
            await watchlistRepository.addToWatchlist(event.uid, event.movieId);
          } catch (e) {
            emit(WatchlistError("Failed to add movie: ${e.toString()}"));
          }
        }
      }
    });

    //* Remove from Watchlist
    on<RemoveFromWatchlist>((event, emit) async {
      if (state is WatchlistLoaded) {
        final currentList = (state as WatchlistLoaded).watchlist;

        if (currentList.contains(event.movieId)) {
          final updatedList = List<String>.from(currentList)
            ..remove(event.movieId);
          emit(WatchlistLoaded(updatedList));
          try {
            await watchlistRepository.removeFromWatchlist(
                event.uid, event.movieId);
          } catch (e) {
            emit(WatchlistError("Failed to remove movie: ${e.toString()}"));
          }
        }
      }
    });
  }
}
