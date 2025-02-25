import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/watchlist_bloc.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class WatchlistButton extends StatefulWidget {
  final String movieId;

  const WatchlistButton({Key? key, required this.movieId}) : super(key: key);

  @override
  State<WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends State<WatchlistButton> {
  late bool isInWatchlist;
  late String uid;

  @override
  void initState() {
    super.initState();

    //* Fetch Current User's UID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      uid = authState.uid;
      context.read<WatchlistBloc>().add(LoadWatchlist(uid));
    } else {
      uid = ""; // Default if not logged in
    }

    //* Default state
    isInWatchlist = false;
  }

  void _toggleWatchlist() {
    final watchlistBloc = context.read<WatchlistBloc>();

    if (isInWatchlist) {
      watchlistBloc.add(RemoveFromWatchlist(uid, widget.movieId));
    } else {
      watchlistBloc.add(AddToWatchlist(uid, widget.movieId));
    }

    //* Toggle UI immediately
    setState(() {
      isInWatchlist = !isInWatchlist;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<WatchlistBloc, WatchlistState>(
      listener: (context, state) {
        if (state is WatchlistLoaded) {
          setState(() {
            isInWatchlist = state.watchlist.contains(widget.movieId);
          });
        }
      },
      child: SizedBox(
        width: 200,
        height: 60, // Ensures consistent width
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isInWatchlist
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _toggleWatchlist,
          icon: Icon(isInWatchlist ? Icons.remove_circle : Icons.add_circle,
              color: Colors.white),
          label: FittedBox(
            fit: BoxFit.scaleDown, // Prevents text overflow issues
            child: Text(
              isInWatchlist ? "Remove from Watchlist" : "Add to Watchlist",
              style:
                  GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
