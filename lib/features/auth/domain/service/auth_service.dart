import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
abstract interface class AuthService{

  Future<Either<Failure, User?>> signIn();

  Future<Either<Failure, bool>> signOut();
}