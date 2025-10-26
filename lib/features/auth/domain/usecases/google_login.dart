import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../service/auth_service.dart';

class GoogleLogin implements UseCase<User?, NoParams>{
  final AuthService authService;
  GoogleLogin(this.authService);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async{
    return await authService.signIn();
  }
}