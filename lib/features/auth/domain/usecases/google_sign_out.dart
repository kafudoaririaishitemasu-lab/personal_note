import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../service/auth_service.dart';

class GoogleSignOut implements UseCase<bool, NoParams>{
  final AuthService authService;
  GoogleSignOut(this.authService);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async{
    return await authService.signOut();
  }
}