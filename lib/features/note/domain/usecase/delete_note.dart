import 'package:fpdart/fpdart.dart';
import 'package:personal_note/features/note/domain/entities/note.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../service/note_service.dart';

class DeleteNote implements UseCase<List<Note>, Note>{
  final NoteService noteService;
  DeleteNote(this.noteService);

  @override
  Future<Either<Failure, List<Note>>> call(Note note) async{
    return await noteService.deleteNote(note: note);
  }
}