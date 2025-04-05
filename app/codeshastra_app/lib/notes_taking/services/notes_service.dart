import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class SharedPreferencesHelper {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }
}

class NotesService {
  static const String _storageKey = 'notes_data';

  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_storageKey) ?? [];

    return notesJson
        .map((noteStr) => Note.fromMap(jsonDecode(noteStr)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> addNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_storageKey) ?? [];

    notesJson.add(jsonEncode(note.toMap()));
    await prefs.setStringList(_storageKey, notesJson);
  }

  Future<void> updateNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_storageKey) ?? [];

    final notesList =
        notesJson.map((noteStr) => Note.fromMap(jsonDecode(noteStr))).toList();

    final index = notesList.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notesList[index] = note;

      await prefs.setStringList(
        _storageKey,
        notesList.map((n) => jsonEncode(n.toMap())).toList(),
      );
    }
  }

  Future<void> deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_storageKey) ?? [];

    final notesList =
        notesJson.map((noteStr) => Note.fromMap(jsonDecode(noteStr))).toList();

    notesList.removeWhere((note) => note.id == id);

    await prefs.setStringList(
      _storageKey,
      notesList.map((n) => jsonEncode(n.toMap())).toList(),
    );
  }
}
