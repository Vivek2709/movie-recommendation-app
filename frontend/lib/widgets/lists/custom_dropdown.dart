import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/blocs/movie_bloc.dart';

class CustomDropdownButton extends StatefulWidget {
  final String label;
  final List<String> items;

  const CustomDropdownButton({
    Key? key,
    required this.label,
    required this.items,
  }) : super(key: key);

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = "All"; // Default filter option
  }

  void _onDropdownChanged(String? newValue) {
    if (newValue != null && newValue != selectedValue) {
      setState(() {
        selectedValue = newValue;
      });

      // Dispatch filter event to MovieBloc
      context.read<MovieBloc>().add(FilterMoviesByGenre(newValue));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<MovieBloc, MovieState>(
      listenWhen: (previous, current) =>
          current is MoviesByCategoryListLoaded &&
          current.selectedGenre != selectedValue,
      listener: (context, state) {
        if (state is MoviesByCategoryListLoaded) {
          setState(() {
            selectedValue = state.selectedGenre;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
            dropdownColor: theme.colorScheme.surface,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            isExpanded: true,
            onChanged: _onDropdownChanged,
            items: widget.items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
