import 'package:encrypt/encrypt.dart';
import 'dart:convert';

// ✅ Use a constant 32-byte key (for AES-256)
final _key = Key.fromBase64(
  base64Encode(utf8.encode('this_is_my_secret_key_32_bytes!!')),
);

// ✅ Use a constant 16-byte IV (for AES-CBC)
final _iv = IV.fromUtf8('16byteslongiv!!8');

/// Encrypt text using AES
String encrypt(String plainText) {
  final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(plainText, iv: _iv);
  return encrypted.base64;
}

/// Decrypt text using AES
String decrypt(String encryptedText) {
  final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
  final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
  return decrypted;
}

// import encrypt plugin