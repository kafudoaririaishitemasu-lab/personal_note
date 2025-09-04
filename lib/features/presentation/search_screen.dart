import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/core/theme/app_pallete.dart';

import '../note/presentation/cubit/note_cubit.dart';
import '../note/presentation/screen/note_screen.dart';
import '../note/presentation/widgets/note_tile.dart';

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
      backgroundColor: orange50,
      appBar: AppBar(
        backgroundColor: orange50,
        title: _buildSearchBar(),
        leadingWidth: 25,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // 📋 Search Results
          Expanded(
            child: BlocBuilder<NotesCubit, NoteState>(
              builder: (context, state) {
                if (state is NoteLoaded) {
                  final filtered = state.notes.where((note) {
                    final title = note.title.toLowerCase();
                    final content = note.content.toLowerCase();
                    return title.contains(query) || content.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text("No matching notes found"),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final note = filtered[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<NotesCubit>(),
                                child: NoteScreen(note: note),
                              ),
                            ),
                          );
                        },
                        child: NoteTile(note: note),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // half circular bend
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        focusNode: _searchFocus,
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search by title or content...",
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

