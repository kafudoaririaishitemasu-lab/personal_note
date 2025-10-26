import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:personal_note/core/services/token_storage_service.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/connection_checker.dart';
import '../data_source/auth_data_source.dart';
import '../../domain/service/auth_service.dart';

class AuthServiceImpl implements AuthService{
  final AuthDataSource authDataSource;
  final ConnectionChecker connectionChecker;
  const AuthServiceImpl(this.authDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, User?>> signIn() async{
    try{
      if(!await (connectionChecker.isConnected)){
        return left(Failure('No Internet Connection'));
      }
      final User? response = await authDataSource.signIn();
      if(response != null){
        final email = response.email ?? "";
        if(email == ""){
          throw ServerException("Failed to SignIn");
        }
      await setEncryptionKeyAndToken(email);
      }else{
        throw ServerException("Failed to SignIn");
      }
      return right(response);
    }on ServerException catch(e){
      return left(Failure(e.message));
    }
  }

  /// Need change in this method according to new logic
  @override
  Future<Either<Failure, bool>> signOut() async{
    try{
      final res = await authDataSource.signOut();
      await deleteEncryptionKeyAndToken();
      return right(res);
    }on Exception catch (e){
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async{
    try{
      if(!await (connectionChecker.isConnected)){
        return left(Failure('No Internet Connection'));
      }
      final User? response = authDataSource.getCurrentUser();
      if(response != null){
        return right(response);
      }else{
        return left(Failure("User not Logged In"));
      }
    }on ServerException catch(e){
      return left(Failure(e.message));
    }
  }
}