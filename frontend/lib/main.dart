import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/blocs/trailer_bloc.dart';
import 'package:frontend/blocs/watchlist_bloc.dart';
import 'package:frontend/core/config/route_config.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/blocs/splash_bloc.dart';
import 'package:frontend/blocs/movie_bloc.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/movie_repository.dart';
import 'package:frontend/data/repositories/trailer_repo.dart';
import 'package:frontend/data/repositories/watchlist_repository.dart';
import 'package:frontend/screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(" Error loading .env file: ${e.toString()}");
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(" Firebase initialization failed: ${e.toString()}");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),
        BlocProvider<SplashBloc>(
          create: (context) => SplashBloc()..add(InitializeApp()),
        ),
        BlocProvider<MovieBloc>(
          create: (context) => MovieBloc(movieRepository: MovieRepository()),
        ),
        BlocProvider<WatchlistBloc>(
          create: (context) =>
              WatchlistBloc(watchlistRepository: WatchlistRepository()),
        ),
        BlocProvider<TrailerBloc>(
          create: (context) =>
              TrailerBloc(trailerRepository: TrailerRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Movie Recommendation App',
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
        onGenerateRoute: RouteConfig.generateRoute,
      ),
    );
  }
}
