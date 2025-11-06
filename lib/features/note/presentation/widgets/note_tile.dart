import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:personal_note/features/note/domain/entities/note.dart';
import 'package:personal_note/features/note/presentation/screen/note_screen.dart';

import '../../../../config/app_pallete.dart';

class NoteTile extends StatefulWidget {
  final Note note;

  const NoteTile({super.key, required this.note});

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {

  Future<void> _authenticateAndNavigate() async {
    if(!widget.note.isLocked){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoteScreen(note: widget.note)),
      );
    }else {
      final LocalAuthentication auth = LocalAuthentication();
      bool didAuthenticate = false;
      try {
        didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to open this note',
          options: const AuthenticationOptions(
            biometricOnly: false,
            // fingerprint first, fallback to device password
            stickyAuth: true,
          ),
        );
      } catch (e) {
        debugPrint("Auth error: $e");
      }

      if (didAuthenticate && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoteScreen(note: widget.note)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _authenticateAndNavigate,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textP2),
        ),
        constraints: const BoxConstraints(maxHeight: 20.0 * 12),
        child: widget.note.isLocked
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                ),
              ),
              // Content: icon + title, centered
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_off,
                      size: 32,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.note.title.isEmpty ? "Note is Locked" : widget.note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                text: widget.note.title.isEmpty ? "Add Title..." : widget.note.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                widget.note.content,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 12,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
