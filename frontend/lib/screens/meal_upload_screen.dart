import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/meal_record.dart';

class MealUploadScreen extends StatefulWidget {
  const MealUploadScreen({super.key});

  @override
  State<MealUploadScreen> createState() => _MealUploadScreenState();
}

class _MealUploadScreenState extends State<MealUploadScreen> {
  File? _selectedImage;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _uploadMeal() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a photo of your meal')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your meal')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      //Upload image to backend/S3
      final uploadResult = await ApiService.uploadMealImage(_selectedImage!);
      final imageUrl = uploadResult['image_url'];

      //Create meal record
      final mealRecord = MealRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: StorageService.userId ?? 'default_user',
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
        description: _descriptionController.text,
        carbsEstimate: double.tryParse(_carbsController.text),
      );

      //Save meal record (Need to create endpoint)
      final success = await ApiService.saveMealRecord(mealRecord);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal uploaded successfully!')),
        );

        //Clear form
        setState(() {
          _selectedImage = null;
          _isUploading = false;
        });
        _descriptionController.clear();
        _carbsController.clear();

        //Navigate back after successful upload
        Navigator.pop(context);
      } else {
        throw Exception('Failed to save meal record');
      }

    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Image Preview Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.photo_camera, color: Colors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Meal Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _selectedImage == null
                        ? Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fastfood, size: 50, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  'No photo selected',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //Meal Details Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description, color: Colors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Meal Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Meal Description *',
                        hintText: 'e.g., Grilled chicken with vegetables and rice',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Carbohydrates (grams)',
                        hintText: 'e.g., 45',
                        border: OutlineInputBorder(),
                        suffixText: 'g',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Optional - helps with glucose predictions',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            //Upload Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _uploadMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Upload Meal',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _carbsController.dispose();
    super.dispose();
  }
}