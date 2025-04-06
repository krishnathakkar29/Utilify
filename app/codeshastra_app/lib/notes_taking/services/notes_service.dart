import 'dart:convert';

import 'package:codeshastra_app/notes_taking/models/note_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesService {
  static const String _storageKey = 'notes_data';

  Future<List<Note>> getNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList(_storageKey) ?? [];

      final notes =
          notesJson.map((noteStr) => Note.fromMap(jsonDecode(noteStr))).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return notes;
    } catch (e) {
      debugPrint('Error loading notes: $e');
      return [];
    }
  }

  Future<bool> addNote(Note note) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList(_storageKey) ?? [];

      // Add validation
      if (note.title.isEmpty && note.content.isEmpty) {
        return false;
      }

      notesJson.insert(0, jsonEncode(note.toMap())); // Insert at beginning
      return await prefs.setStringList(_storageKey, notesJson);
    } catch (e) {
      debugPrint('Error adding note: $e');
      return false;
    }
  }

  Future<bool> updateNote(Note note) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList(_storageKey) ?? [];

      final notesList =
          notesJson
              .map((noteStr) => Note.fromMap(jsonDecode(noteStr)))
              .toList();

      final index = notesList.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        notesList[index] = note;
        final updatedJson =
            notesList.map((n) => jsonEncode(n.toMap())).toList();
        return await prefs.setStringList(_storageKey, updatedJson);
      }
      return false;
    } catch (e) {
      debugPrint('Error updating note: $e');
      return false;
    }
  }
}
