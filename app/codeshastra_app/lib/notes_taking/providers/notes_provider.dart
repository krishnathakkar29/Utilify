import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService = NotesService();
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _notesService.getNotes();
    } catch (e) {
      _error = 'Failed to load notes';
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addNote(String title, String content) async {
    try {
      final note = Note(title: title.trim(), content: content.trim());

      final success = await _notesService.addNote(note);
      if (success) {
        _notes.insert(0, note);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error adding note: $e');
      return false;
    }
  }

  Future<bool> updateNote(String id, String title, String content) async {
    try {
      final index = _notes.indexWhere((note) => note.id == id);
      if (index != -1) {
        final updatedNote = _notes[index].copyWith(
          title: title.trim(),
          content: content.trim(),
        );

        final success = await _notesService.updateNote(updatedNote);
        if (success) {
          _notes[index] = updatedNote;
          _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating note: $e');
      return false;
    }
  }

  void deleteNote(String noteId) {
    _notes.removeWhere((note) => note.id == noteId);
    notifyListeners();
  }
}
