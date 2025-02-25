import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/dialogs/movie_bottom_sheet.dart';
import 'package:frontend/widgets/loaders/circular_progress_indicator.dart';

class MovieCard extends StatefulWidget {
  final Map<String, dynamic> movieData; // 🔹 Pass entire movieData

  const MovieCard({Key? key, required this.movieData}) : super(key: key);

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String posterUrl = widget.movieData['Poster'] ?? '';

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => MovieBottomSheet(movieData: widget.movieData),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isHovered ? 0.5 : 0.3),
                blurRadius: isHovered ? 12 : 8,
                spreadRadius: isHovered ? 4 : 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: posterUrl,
              height: 220,
              width: 150,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholderCard(theme),
              errorWidget: (context, url, error) => _buildErrorCard(theme),
            ),
          ),
        ),
      ),
    );
  }

  //* Loading Placeholder
  Widget _buildPlaceholderCard(ThemeData theme) {
    return Container(
      height: 220,
      width: 150,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CustomCircularProgressIndicator()),
    );
  }

  //* Error Placeholder
  Widget _buildErrorCard(ThemeData theme) {
    return Container(
      height: 220,
      width: 150,
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.error, color: Colors.red),
      ),
    );
  }
}
