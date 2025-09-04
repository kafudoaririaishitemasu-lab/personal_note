import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:personal_note/core/theme/app_pallete.dart';
import 'package:personal_note/features/presentation/home/widgets/cuved_search_bar.dart';
import 'package:personal_note/features/presentation/search_screen.dart';

import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/cubit/note_cubit.dart';
import '../../../note/presentation/screen/note_screen.dart';
import '../../../note/presentation/widgets/note_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: orange50,
        body: BlocBuilder<NotesCubit, NoteState>(
          builder: (context, state) {
            if(state is NoteLoading){
              return const Center(child: CircularProgressIndicator());
            } else if(state is NoteLoaded){
              if (state.notes.isEmpty) {
                return const Center(child: Text("No notes available"));
              }
              return Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  CurvedSearchBar(navigatedScreen: SearchScreen()),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.notes.length,
                      itemBuilder: (context, index) {
                        final note = state.notes[index];
                        return NoteTile(note: note);
                      },
                    ),
                  ),
                ],
              );
            }else{
              return Text("Something went wrong");
            }
          },
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: Colors.pink.shade50,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.note_add),
              label: "New Note",
              onTap: () async {
                final newNote = Note(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: "",
                  content: "",
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<NotesCubit>(),
                      child: NoteScreen(note: newNote),
                    ),
                  ),
                ).then((_) {
                    context.read<NotesCubit>().loadNotes();
                });
              },
            ),
            // SpeedDialChild(
            //   child: const Icon(Icons.lock),
            //   label: "Locked Notes",
            //   onTap: () {
            //     // Locked notes flow
            //   },
            // ),
          ],
        ),
    );
  }
}