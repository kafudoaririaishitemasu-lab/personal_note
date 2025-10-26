import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:personal_note/core/secret/app_secret.dart';

const storage = FlutterSecureStorage();

Future<void> setEncryptionKeyAndToken(String email) async{
  String combinedData = email + const_salt;

  var bytes = utf8.encode(combinedData);
  var digest = sha256.convert(bytes);

  String generatedKey = digest.toString();
  await storage.write(key: enc_key, value: generatedKey);
  await storage.write(key: "token", value: email);
}

Future<String?> getToken() async{
  final token =  await storage.read(key: 'token');
  if(token != null){
    return token;
  }else{
    return null;
  }
}

Future<String?> getEncryptionKey() async{
  final encryptionKey =  await storage.read(key: enc_key);
  if(encryptionKey != null){
    return encryptionKey;
  }else{
    return null;
  }
}

Future<bool> deleteEncryptionKeyAndToken() async{
  await storage.delete(key: 'token');
  await storage.delete(key: enc_key);
  return true;
}

// Future<String> getLoggedUserRole() async{
//   String? token = await storage.read(key: 'jwt_token');
//   Map<String, dynamic> payload = JwtDecoder.decode(token!);
//   return payload['role'];
// }
//
// Future<String?> getLoggedUserId() async{
//   String? token = await storage.read(key: 'jwt_token');
//   if(token == null){
//     return null;
//   }
//   Map<String, dynamic> payload = JwtDecoder.decode(token);
//   return payload['sub'];
// }
//
// Future<String?> getVerifiedJwtToken() async {
//   final token =  await storage.read(key: 'jwt_token');
//   if(token != null){
//     final fetchedToken = await checkExpiration(token);
//     if(fetchedToken != null){
//       return fetchedToken;
//     }else{
//       return null;
//     }
//   }else{
//     return null;
//   }
// }
//
// Future<String?> checkExpiration(String token) async {
//   final payload = JwtDecoder.decode(token);
//   final expiryTimestamp = payload['exp'] * 1000;
//   final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//   final timeLeft = expiryTimestamp - currentTimestamp;
//   if (timeLeft <= 0) {
//     await deleteJwtToken();
//     return null;
//   }
//   if (timeLeft < 7 * 24 * 60 * 60 * 1000) {
//     return await refreshToken(token);
//   }
//   return token;
// }
//
// Future<String?> refreshToken(String token) async {
//   try {
//     final response = await authedDio.post(
//       "${MyApp.mainUrl}/auth/refresh-token",
//       options: Options(headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       }),
//       data: {
//         'token': token
//       },
//     );
//     if (response.statusCode == 200 && response.data['data'] != null) {
//       String newToken = response.data['data']['token'];
//       await setJwtToken(newToken);
//       return newToken;
//     } else {
//       return null;
//     }
//   } on DioException {
//     return null;
//   }
// }

