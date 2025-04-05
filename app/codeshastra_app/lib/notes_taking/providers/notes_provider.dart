import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService = NotesService();
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _notesService.getNotes();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String title, String content) async {
    final note = Note(
      title: title,
      content: content,
    );

    try {
      await _notesService.addNote(note);
      _notes.insert(0, note);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }

  Future<void> updateNote(String id, String title, String content) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final updatedNote = _notes[index].copyWith(
        title: title,
        content: content,
      );

      try {
        await _notesService.updateNote(updatedNote);
        _notes[index] = updatedNote;
        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating note: $e');
      }
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _notesService.deleteNote(id);
      _notes.removeWhere((note) => note.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }
}
