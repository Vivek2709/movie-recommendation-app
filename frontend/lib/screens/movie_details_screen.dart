import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/movie_bloc.dart';
import 'package:frontend/widgets/buttons/watchlist_button.dart';
import 'package:frontend/widgets/buttons/trailer_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MovieDetailScreen extends StatefulWidget {
  final Map<String, dynamic> movieData;

  const MovieDetailScreen({Key? key, required this.movieData})
      : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool showFullPlot = false;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  void _fetchMovieDetails() {
    context.read<MovieBloc>().add(FetchMovieByTitle(widget.movieData['Title']));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.movieData['Title']),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MovieLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MovieError) {
            return Center(
              child: Text(
                "Error loading movie details!",
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }

          if (state is MovieLoaded) {
            final movie = state.movieData;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMoviePoster(movie),
                  _buildMovieInfo(movie, theme),
                  _buildRatings(movie),
                  _buildGenreAndLanguage(movie),
                  _buildActionButtons(movie),
                  _buildPlot(movie),
                  _buildCastAndCrew(movie),
                  _buildBoxOfficeAndAwards(movie),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }

          return const Center(child: Text("No details available"));
        },
      ),
    );
  }

  //*Movie Poster
  Widget _buildMoviePoster(Map<String, dynamic> movie) {
    return Stack(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(movie['Poster'] ?? ''),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          top: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: movie['Poster'] ?? '',
              width: 120,
              height: 180,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 120),
            ),
          ),
        ),
      ],
    );
  }

  //*Movie Info
  Widget _buildMovieInfo(Map<String, dynamic> movie, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie['Title'] ?? '',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                  "📅 ${movie['Year'] ?? 'N/A'}  •  ⏳ ${movie['Runtime'] ?? 'N/A'}"),
              const SizedBox(width: 10),
              const Icon(Icons.star, color: Colors.amber, size: 18),
              Text(" ${movie['imdbRating'] ?? 'N/A'}"),
            ],
          ),
        ],
      ),
    );
  }

  //*Ratings
  Widget _buildRatings(Map<String, dynamic> movie) {
    final ratings = movie['Ratings'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: ratings.isNotEmpty
            ? ratings
                .map<Widget>((rating) =>
                    _buildRatingBadge(rating['Source'], rating['Value']))
                .toList()
            : [const Text("No Ratings Available")],
      ),
    );
  }

  //*Fixed `_buildRatingBadge()`
  Widget _buildRatingBadge(String source, String rating) {
    Color backgroundColor;
    String iconPath;
    bool overrideIconColor = true;
    Color? iconColor;

    switch (source) {
      case "Internet Movie Database":
        backgroundColor = const Color(0xFFF5C518); // IMDb Yellow
        iconPath = 'assets/icons/imdb.svg';
        iconColor = Colors.black; // Force black for IMDb icon
        break;
      case "Rotten Tomatoes":
        backgroundColor = const Color(0xFFFA320A); // Rotten Tomatoes Red
        iconPath = 'assets/icons/tomatoes-cherry.svg';
        overrideIconColor = false; // Use native colors for Rotten Tomatoes
        break;
      case "Metacritic":
        backgroundColor = const Color(0xFFF5C518); // Metacritic Gray
        iconPath = 'assets/icons/metacrtic.svg';
        iconColor = Colors.black; // Use native colors for Metacritic
        break;
      default:
        backgroundColor = Colors.grey.shade700;
        iconPath = 'assets/icons/star.svg';
        iconColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            height: 20,
            width: 20,
            // Apply the color filter only if we're overriding native colors.
            colorFilter: overrideIconColor
                ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            rating,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  //*Genre & Language
  Widget _buildGenreAndLanguage(Map<String, dynamic> movie) {
    List<String> genres = [];

    if (movie['Genre'] is String) {
      genres =
          (movie['Genre'] as String).split(',').map((e) => e.trim()).toList();
    } else if (movie['Genre'] is List) {
      genres = List<String>.from(movie['Genre']);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 6,
        children: [
          for (var genre in genres) _buildChip(genre),
          _buildChip(movie['Language'] ?? 'Unknown'),
        ],
      ),
    );
  }

  //*Genre Chips
  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blueGrey.withOpacity(0.2),
    );
  }

  //*Watchlist & Trailer Buttons
  Widget _buildActionButtons(Map<String, dynamic> movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: WatchlistButton(movieId: movie['imdbID'] ?? '')),
          SizedBox(
            width: 15,
          ),
          Expanded(child: TrailerButton(movieTitle: movie['Title'] ?? '')),
        ],
      ),
    );
  }

  //*Cast & Crew
  Widget _buildCastAndCrew(Map<String, dynamic> movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text("🎭 Cast: ${movie['Actors'] ?? 'Unknown'}",
          style: const TextStyle(color: Colors.white70)),
    );
  }

  //*Box Office & Awards
  Widget _buildBoxOfficeAndAwards(Map<String, dynamic> movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text("🏆 Awards: ${movie['Awards'] ?? 'N/A'}",
          style: const TextStyle(color: Colors.white70)),
    );
  }

  Widget _buildPlot(Map<String, dynamic> movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📖 Plot",
              style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
              showFullPlot
                  ? movie['Plot']
                  : "${movie['Plot'].substring(0, 100)}...",
              style: const TextStyle(color: Colors.white70)),
          TextButton(
            onPressed: () => setState(() => showFullPlot = !showFullPlot),
            child: Text(showFullPlot ? "Show Less" : "Read More"),
          ),
        ],
      ),
    );
  }
}
