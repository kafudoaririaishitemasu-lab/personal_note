// import 'package:encrypt/encrypt.dart' as enc;
//
// /// 32-byte secret key (AES-256)
// const _secretKey = 'your32bitlongencryptionkey!!0931'; // must be 32 chars
//
// /// 16-byte IV (Initialization Vector)
// const _ivString = '16byteslongiv!!99'; // must be 16 chars
//
// // Create key & IV
// final _key = enc.Key.fromUtf8(_secretKey);
// final _iv = enc.IV.fromUtf8(_ivString);
//
// // Configure AES Encrypter
// final _encrypter = enc.Encrypter(
//   enc.AES(_key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
// );
//
// /// Encrypts plain text → Base64 string
// String encryptText(String plainText) {
//   final encrypted = _encrypter.encrypt(plainText, iv: _iv);
//   return encrypted.base64;
// }
//
// /// Decrypts Base64 string → plain text
// String decryptText(String encryptedText) {
//   final decrypted =
//   _encrypter.decrypt(enc.Encrypted.fromBase64(encryptedText), iv: _iv);
//   return decrypted;
// }
