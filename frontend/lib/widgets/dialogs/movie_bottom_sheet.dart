import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MovieBottomSheet extends StatelessWidget {
  final Map<String, dynamic> movieData;
  const MovieBottomSheet({Key? key, required this.movieData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final String posterUrl = movieData['Poster'] ?? '';
    final List ratings = movieData['Ratings'] ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Curved Handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),

            // Movie Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: posterUrl,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey.shade800,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.movie, size: 200, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // Movie Title
            Text(
              movieData['Title'] ?? 'Unknown Title',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Movie Language with improved styling
            Text.rich(
              TextSpan(
                // text: "Language: ",
                // style: textTheme.bodyMedium?.copyWith(
                //   fontWeight: FontWeight.bold,
                //   color: theme.colorScheme.primary,
                // ),
                children: [
                  TextSpan(
                    text: movieData['Language'] ?? 'Unknown',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Ratings Section
            if (ratings.isNotEmpty)
              Column(
                children: [
                  // Text(
                  //   "Ratings:",
                  //   style: textTheme.titleSmall?.copyWith(
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: ratings.map((rating) {
                      return _buildRatingBadge(
                        rating['Source'] ?? 'Unknown Source',
                        rating['Value'] ?? 'N/A',
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // Short Plot with improved styling
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                movieData['Plot'] ?? 'No description available',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // More Details Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/movieDetails',
                  arguments: movieData,
                );
              },
              child: Text("More Details"),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  //* Dynamic Rating Badge
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
}
