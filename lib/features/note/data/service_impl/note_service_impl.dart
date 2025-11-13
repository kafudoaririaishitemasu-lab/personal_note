import 'package:fpdart/fpdart.dart';
import 'package:personal_note/core/error/exceptions.dart';
import 'package:personal_note/core/error/failures.dart';
import 'package:personal_note/core/network/connection_checker.dart';
import 'package:personal_note/features/note/data/data_source/note_cloud_data_source.dart';
import 'package:personal_note/features/note/domain/entities/note.dart';
import 'package:personal_note/features/note/domain/service/note_service.dart';

class NoteServiceImpl implements NoteService{
  final ConnectionChecker connectionChecker;
  final NoteDataSource noteDataSource;

  NoteServiceImpl(this.connectionChecker, this.noteDataSource);

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
        if (await connectionChecker.isConnected) {
          final cloud = await noteDataSource.getCloudNotes();
          return right(cloud);
        }else{
          final local = noteDataSource.getLocalNotes();
          return right(local);
        }
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> saveNote({required Note note}) async {
    try{
      if (await connectionChecker.isConnected) {
        final res = await noteDataSource.saveNoteLocalAndCloud(note: note);
        return right(res);
      }else{
        final res = await noteDataSource.saveNoteLocal(note: note);
        return right(res);
      }
    } on ServerException catch (e){
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> deleteNote({required Note note}) async{
    try{
      if(await connectionChecker.isConnected){
        final res = await noteDataSource.deleteNoteLocalAndCloud(note: note);
        return right(res);
      }else{
        final res = noteDataSource.deleteNoteLocal(note: note);
        return right(res);
      }
    } on ServerException catch(e){
      return left(Failure(e.message));
    }
  }

}