import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/notes_provider.dart';
import 'screens/notes_screen.dart';

class NotesModule extends StatelessWidget {
  const NotesModule({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotesProvider(),
      child: const NotesScreen(),
    );
  }
}
