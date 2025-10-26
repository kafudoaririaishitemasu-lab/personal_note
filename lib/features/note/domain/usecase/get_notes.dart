import 'package:fpdart/fpdart.dart';
import 'package:personal_note/features/note/domain/entities/note.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../service/note_service.dart';

class GetNotes implements UseCase<List<Note>, NoParams>{
  final NoteService noteService;
  GetNotes(this.noteService);

  @override
  Future<Either<Failure, List<Note>>> call(NoParams params) async{
    return await noteService.getNotes();
  }
}