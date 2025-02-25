import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/blocs/trailer_bloc.dart';

class TrailerButton extends StatefulWidget {
  final String movieTitle;

  const TrailerButton({Key? key, required this.movieTitle}) : super(key: key);

  @override
  _TrailerButtonState createState() => _TrailerButtonState();
}

class _TrailerButtonState extends State<TrailerButton> {
  String? trailerUrl;

  @override
  void initState() {
    super.initState();
    context.read<TrailerBloc>().add(FetchTrailer(widget.movieTitle));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrailerBloc, TrailerState>(
      listener: (context, state) {
        if (state is TrailerLoaded) {
          setState(() {
            trailerUrl = state.trailerUrl;
          });
        }
      },
      child: ElevatedButton.icon(
        onPressed:
            trailerUrl != null ? () => _launchTrailer(trailerUrl!) : null,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text("Watch Trailer"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _launchTrailer(String url) async {
    final Uri trailerUri = Uri.parse(url);

    debugPrint("🔗 Attempting to open: $url");

    try {
      bool launched = await launchUrl(
        trailerUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint("Failed to launch: $url");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }
  }
}
