import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:personal_note/config/app_pallete.dart';
import 'package:personal_note/core/router/app_router.dart';
import 'package:personal_note/core/utils/snackbar.dart';
import 'package:personal_note/core/utils/encryptor.dart';
import 'package:personal_note/features/note/presentation/bloc/note_bloc.dart';
import 'package:personal_note/features/presentation/screens/search_screen.dart';
import 'package:personal_note/features/presentation/widgets/app_drawer.dart';
import 'package:personal_note/init_dependencies.dart';
import '../../note/domain/entities/note.dart';
import '../../note/presentation/screen/note_screen.dart';
import '../../note/presentation/widgets/note_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteBloc>().add(NoteGetEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: GestureDetector(
          child: const Text(
            "My Notes",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            if (state is NoteLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            else if (state is NoteLoaded) {
              final notes = state.notes
                  .where((note) => note.isTrashed == false)
                  .toList();
              if (notes.isEmpty) {
                return const Center(child: Text("No notes yet. Create one!"));
              }
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      serviceLocator<AppRouter>().pushWithContext(
                        context,
                        SearchScreen(),
                        isMinimal: true,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(25),
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
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "Search notes...",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
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
            } else {
              return const Center(child: Text("Something went wrong"));
            }
          },
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: lightPrimary,
        foregroundColor: whiteColor,
        children: [
          SpeedDialChild(
            child: Icon(Icons.note_add),
            label: "New Note",
            // backgroundColor: lightSecondary,
            // labelBackgroundColor: lightSecondary,
            onTap: () {
              final newNote = Note(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: "",
                content: "",
                isLocked: false,
                createdAt: DateTime.now().toIso8601String(),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<NoteBloc>(),
                    child: NoteScreen(note: newNote),
                  ),
                ),
              ).then((_) {
                context.read<NoteBloc>().add(NoteGetEvent());
              });
            },
          ),
        ],
      ),
    );
  }
}
