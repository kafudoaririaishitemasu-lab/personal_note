/// TODO Enhance encryption method for better scalability;

// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:personal_note/core/secret/app_secret.dart';
//
// const storage = FlutterSecureStorage();
//
// Future<void> setEncryptionKeyAndToken(String email) async{
//   String combinedData = email + const_salt;
//
//   var bytes = utf8.encode(combinedData);
//   var digest = sha256.convert(bytes);
//
//   String generatedKey = digest.toString();
//   await storage.write(key: enc_key, value: generatedKey);
//   await storage.write(key: "token", value: email);
// }
//
// Future<String?> getToken() async{
//   final token =  await storage.read(key: 'token');
//   if(token != null){
//     return token;
//   }else{
//     return null;
//   }
// }
//
// Future<String?> getEncryptionKey() async{
//   final encryptionKey =  await storage.read(key: enc_key);
//   if(encryptionKey != null){
//     return encryptionKey;
//   }else{
//     return null;
//   }
// }
//
// Future<bool> deleteEncryptionKeyAndToken() async{
//   await storage.delete(key: 'token');
//   await storage.delete(key: enc_key);
//   return true;
// }
//
//
