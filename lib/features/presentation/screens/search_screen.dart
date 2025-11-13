import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/core/utils/loader.dart';
import 'package:personal_note/features/note/presentation/bloc/note_bloc.dart';
import '../../../config/app_pallete.dart';
import '../../note/presentation/widgets/note_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _searchFocus = FocusNode();

  String query = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Search Notes", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          /// List of Notes
          Expanded(
            child: BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoaded) {
                  final filtered = state.notes.where((note) {
                    final title = note.title.toLowerCase();
                    final content = note.content.toLowerCase();
                    return (title.contains(query) || content.contains(query)) && note.isTrashed == false;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text("No matching notes found"),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => NoteTile(note: filtered[index]),
                  );
                }
                else{
                  return loader();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(){
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30), // half circular bend
        boxShadow: [
          BoxShadow(
            color:
            Theme.of(context).brightness == Brightness.light
                ? grey300
                : grey800,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        focusNode: _searchFocus,
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search by title or content...",
          hintStyle: TextStyle(
            color: Colors.grey
          ),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            query = value.trim().toLowerCase();
          });
        },
      ),
    );
  }
}

