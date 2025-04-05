import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';

class NoteDetailScreen extends StatefulWidget {
  final String? noteId;

  const NoteDetailScreen({
    super.key,
    this.noteId,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isEditing = false;
  late Note? _currentNote;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.noteId == null;
    
    if (widget.noteId != null) {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      _currentNote = notesProvider.notes.firstWhere(
        (note) => note.id == widget.noteId,
        orElse: () => Note(title: '', content: ''),
      );
      
      _titleController.text = _currentNote?.title ?? '';
      _contentController.text = _currentNote?.content ?? '';
    } else {
      _currentNote = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    
    if (widget.noteId == null) {
      notesProvider.addNote(title, content);
    } else {
      notesProvider.updateNote(widget.noteId!, title, content);
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'View Note'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              enabled: _isEditing,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentController,
                enabled: _isEditing,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Write your note here...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
