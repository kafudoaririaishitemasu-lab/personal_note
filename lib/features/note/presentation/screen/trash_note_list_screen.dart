import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/config/app_pallete.dart';
import 'package:personal_note/features/note/presentation/bloc/note_bloc.dart';

import '../widgets/note_tile.dart';

class TrashNoteListScreen extends StatefulWidget {
  const TrashNoteListScreen({super.key});

  @override
  State<TrashNoteListScreen> createState() => _TrashNoteListScreenState();
}

class _TrashNoteListScreenState extends State<TrashNoteListScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Trash Notes", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
          child: BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if(state is NoteLoading){
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }
                else if(state is NoteLoaded){
                  final notes = state.notes.where((note) => note.isTrashed == true).toList();
                  if(notes.isEmpty){
                    return const Center(child: Text("No notes yet. Create one!"));
                  }
                  return Column(
                    children: [
                      // GestureDetector(
                      //   onTap: () {},
                      //   child: Container(
                      //     margin: const EdgeInsets.all(16),
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 20, vertical: 14),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(25),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.grey.shade300,
                      //           blurRadius: 3,
                      //           offset: const Offset(0, 2),
                      //         ),
                      //       ],
                      //     ),
                      //     child: Row(
                      //       children: const [
                      //         Icon(Icons.search, color: Colors.grey),
                      //         SizedBox(width: 8),
                      //         Text("Search notes...",
                      //             style: TextStyle(color: Colors.grey)),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: notes.length,
                          itemBuilder: (context, index) =>
                              NoteTile(note: notes[index]),
                        ),
                      ),
                    ],
                  );
                }else{
                  return const Center(child: Text("Something went wrong!"));
                }
              }
          )),
    );
  }
}
