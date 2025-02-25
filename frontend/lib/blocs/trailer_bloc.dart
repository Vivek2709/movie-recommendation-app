import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/data/repositories/trailer_repo.dart';

//* Events
abstract class TrailerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchTrailer extends TrailerEvent {
  final String movieTitle;
  FetchTrailer(this.movieTitle);

  @override
  List<Object> get props => [movieTitle];
}

//* States
abstract class TrailerState extends Equatable {
  @override
  List<Object> get props => [];
}

class TrailerInitial extends TrailerState {}

class TrailerLoading extends TrailerState {}

class TrailerLoaded extends TrailerState {
  final String trailerUrl;
  TrailerLoaded(this.trailerUrl);

  @override
  List<Object> get props => [trailerUrl];
}

class TrailerError extends TrailerState {
  final String errorMessage;
  TrailerError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

//* BLoC
class TrailerBloc extends Bloc<TrailerEvent, TrailerState> {
  final TrailerRepository trailerRepository;

  TrailerBloc({required this.trailerRepository}) : super(TrailerInitial()) {
    on<FetchTrailer>((event, emit) async {
      emit(TrailerLoading());
      try {
        final trailerUrl =
            await trailerRepository.fetchTrailer(event.movieTitle);
        if (trailerUrl != null) {
          emit(TrailerLoaded(trailerUrl));
        } else {
          emit(TrailerError("Trailer not found"));
        }
      } catch (e) {
        emit(TrailerError("Failed to fetch trailer"));
      }
    });
  }
}
