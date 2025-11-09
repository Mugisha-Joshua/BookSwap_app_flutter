import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/book_listing.dart';
import '../services/book_service.dart';
import '../theme/app_theme.dart';

class PostBookScreen extends StatefulWidget {
  final BookListing? bookToEdit;
  
  const PostBookScreen({super.key, this.bookToEdit});

  @override
  State<PostBookScreen> createState() => _PostBookScreenState();
}

class _PostBookScreenState extends State<PostBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _swapForController = TextEditingController();
  final _imagePicker = ImagePicker();
  String _selectedCondition = 'Used';
  final List<String> _conditions = ['New', 'Like New', 'Good', 'Used'];
  final _bookService = BookService();
  bool _isLoading = false;
  bool _isUploading = false;
  String? _imageBase64;

  @override
  void initState() {
    super.initState();
    if (widget.bookToEdit != null) {
      _titleController.text = widget.bookToEdit!.title;
      _authorController.text = widget.bookToEdit!.author;
      _swapForController.text = widget.bookToEdit!.swapFor;
      _selectedCondition = widget.bookToEdit!.condition;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _swapForController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      String base64Image;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        base64Image = base64Encode(bytes);
      } else {
        final file = File(picked.path);
        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.path,
          '${file.path}_compressed.jpg',
          quality: 70,
          minWidth: 800,
          minHeight: 800,
        );
        base64Image = base64Encode(await compressed!.readAsBytes());
      }

      setState(() {
        _imageBase64 = base64Image;
        _isUploading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed')),
        );
      }
      setState(() => _isUploading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in first')),
          );
        }
        return;
      }



      if (widget.bookToEdit != null) {
        // Update existing book
        final updatedBook = BookListing(
          id: widget.bookToEdit!.id,
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          swapFor: _swapForController.text.trim(),
          condition: _selectedCondition,
          userId: user.uid,
          userName: user.displayName ?? 'Anonymous',
          createdAt: widget.bookToEdit!.createdAt,
          imageUrl: _imageBase64 ?? widget.bookToEdit!.imageUrl,
          status: widget.bookToEdit!.status,
        );
        await _bookService.updateBook(widget.bookToEdit!.id, updatedBook);
      } else {
        // Add new book
        final book = BookListing(
          id: '',
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          swapFor: _swapForController.text.trim(),
          condition: _selectedCondition,
          userId: user.uid,
          userName: user.displayName ?? 'Anonymous',
          createdAt: DateTime.now(),
          imageUrl: _imageBase64,
        );
        await _bookService.addBook(book);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.bookToEdit != null 
              ? 'Book updated successfully!' 
              : 'Book posted successfully!'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (_imageBase64 == null || _imageBase64!.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: AppTheme.darkBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to add book cover',
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    return Image.memory(
      base64Decode(_imageBase64!),
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(widget.bookToEdit != null ? 'Edit Book' : 'Post a Book'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book Cover Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.darkBlue.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImagePreview(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a book title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _swapForController,
                decoration: const InputDecoration(
                  labelText: 'Swap For',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter what you want to swap for';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Condition',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _conditions.map((condition) {
                  final isSelected = _selectedCondition == condition;
                  return ChoiceChip(
                    label: Text(condition),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCondition = condition;
                      });
                    },
                    selectedColor: AppTheme.yellowAccent,
                    backgroundColor: AppTheme.white,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.textDark : AppTheme.textLight,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yellowAccent,
                  foregroundColor: AppTheme.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.bookToEdit != null ? 'Update' : 'Post',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
