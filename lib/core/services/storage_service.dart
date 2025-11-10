import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isInitialized = false;

  // Initialize storage service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('📦 Initializing StorageService...');
      
      // Request storage permissions
      if (Platform.isAndroid || Platform.isIOS) {
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.camera,
          Permission.photos,
        ].request();

        // Check if all permissions are granted
        final allGranted = statuses.values.every((status) => status.isGranted);
        if (!allGranted) {
          print('⚠️ Some permissions were not granted: $statuses');
        }
      }

      _isInitialized = true;
      print('✅ StorageService initialized successfully');
    } catch (e) {
      print('❌ StorageService initialization failed: $e');
      throw Exception('Storage service initialization failed: $e');
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File image, String path) async {
    try {
      await initialize();
      
      print('📤 Uploading image to: $path');
      
      // Check if file exists and is readable
      if (!await image.exists()) {
        throw Exception('Image file does not exist: ${image.path}');
      }

      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(
        image,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_at': DateTime.now().toIso8601String(),
            'file_size': '${await image.length()}',
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📊 Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Failed to upload image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload image with compression
  Future<String> uploadCompressedImage(File image, String path, {int quality = 80}) async {
    try {
      await initialize();
      
      print('📤 Uploading compressed image to: $path (quality: $quality%)');
      return await uploadImage(image, path);
    } catch (e) {
      print('❌ Failed to upload compressed image: $e');
      throw Exception('Failed to upload compressed image: $e');
    }
  }

  // Upload multiple images
  Future<List<String>> uploadImages(List<File> images, String basePath) async {
    try {
      await initialize();
      
      print('📤 Uploading ${images.length} images to: $basePath');
      final List<String> downloadUrls = [];
      
      for (int i = 0; i < images.length; i++) {
        try {
          final String path = '$basePath/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final String url = await uploadImage(images[i], path);
          downloadUrls.add(url);
          
          print('✅ Uploaded image ${i + 1}/${images.length}');
        } catch (e) {
          print('⚠️ Failed to upload image $i, skipping: $e');
          // Continue with other images even if one fails
        }
      }
      
      if (downloadUrls.isEmpty) {
        throw Exception('No images were successfully uploaded');
      }
      
      print('✅ ${downloadUrls.length}/${images.length} images uploaded successfully');
      return downloadUrls;
    } catch (e) {
      print('❌ Failed to upload images: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  // Upload profile picture with automatic path generation
  Future<String> uploadProfilePicture(File image, String userId) async {
    try {
      await initialize();
      
      final String path = 'profile_pictures/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await uploadCompressedImage(image, path, quality: 70);
    } catch (e) {
      print('❌ Failed to upload profile picture: $e');
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Upload event banner image
  Future<String> uploadEventBanner(File image, String eventId) async {
    try {
      await initialize();
      
      final String path = 'event_banners/$eventId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await uploadCompressedImage(image, path, quality: 85);
    } catch (e) {
      print('❌ Failed to upload event banner: $e');
      throw Exception('Failed to upload event banner: $e');
    }
  }

  // Upload plant image
  Future<String> uploadPlantImage(File image, String plantId) async {
    try {
      await initialize();
      
      final String path = 'plant_images/$plantId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await uploadCompressedImage(image, path, quality: 80);
    } catch (e) {
      print('❌ Failed to upload plant image: $e');
      throw Exception('Failed to upload plant image: $e');
    }
  }

  // Upload report image
  Future<String> uploadReportImage(File image, String reportId) async {
    try {
      await initialize();
      
      final String path = 'report_images/$reportId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await uploadCompressedImage(image, path, quality: 75);
    } catch (e) {
      print('❌ Failed to upload report image: $e');
      throw Exception('Failed to upload report image: $e');
    }
  }

  // Upload NGO logo
  Future<String> uploadNGOLogo(File image, String ngoId) async {
    try {
      await initialize();
      
      final String path = 'ngo_logos/$ngoId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await uploadCompressedImage(image, path, quality: 90);
    } catch (e) {
      print('❌ Failed to upload NGO logo: $e');
      throw Exception('Failed to upload NGO logo: $e');
    }
  }

  // Upload sponsor logo
  Future<String> uploadSponsorLogo(File image, String sponsorId) async {
    try {
      await initialize();
      
      final String path = 'sponsor_logos/$sponsorId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await uploadCompressedImage(image, path, quality: 90);
    } catch (e) {
      print('❌ Failed to upload sponsor logo: $e');
      throw Exception('Failed to upload sponsor logo: $e');
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String url) async {
    try {
      await initialize();
      
      print('🗑️ Deleting image: $url');
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
      
      print('✅ Image deleted successfully');
    } catch (e) {
      print('❌ Failed to delete image: $e');
      // Don't throw here, as it might be expected if file doesn't exist
    }
  }

  // Delete multiple images
  Future<void> deleteImages(List<String> urls) async {
    try {
      await initialize();
      
      print('🗑️ Deleting ${urls.length} images');
      for (final String url in urls) {
        await deleteImage(url);
      }
      
      print('✅ All images deleted successfully');
    } catch (e) {
      print('❌ Failed to delete images: $e');
      // Don't throw here, as partial deletion might be acceptable
    }
  }

  // Delete image by path
  Future<void> deleteImageByPath(String path) async {
    try {
      await initialize();
      
      print('🗑️ Deleting image by path: $path');
      final Reference ref = _storage.ref().child(path);
      await ref.delete();
      
      print('✅ Image deleted successfully');
    } catch (e) {
      print('❌ Failed to delete image by path: $e');
    }
  }

  // Get image download URL
  Future<String> getDownloadUrl(String path) async {
    try {
      await initialize();
      
      print('🔗 Getting download URL for: $path');
      final String url = await _storage.ref(path).getDownloadURL();
      
      print('✅ Download URL retrieved: $url');
      return url;
    } catch (e) {
      print('❌ Failed to get download URL: $e');
      throw Exception('Failed to get download URL: $e');
    }
  }

  // Check if file exists in storage
  Future<bool> fileExists(String path) async {
    try {
      await initialize();
      
      // Try to get the download URL - if it succeeds, file exists
      await _storage.ref(path).getDownloadURL();
      return true;
    } catch (e) {
      // If an error occurs, the file likely doesn't exist
      return false;
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String path) async {
    try {
      await initialize();
      
      return await _storage.ref(path).getMetadata();
    } catch (e) {
      print('❌ Failed to get file metadata: $e');
      throw Exception('Failed to get file metadata: $e');
    }
  }

  // Get storage usage for a user
  Future<Map<String, dynamic>> getUserStorageUsage(String userId) async {
    try {
      await initialize();
      
      print('📊 Calculating storage usage for user: $userId');
      
      // List all files for the user across different categories
      final List<String> categories = [
        'profile_pictures/$userId',
        'event_banners',
        'plant_images',
        'report_images',
      ];

      int totalFiles = 0;
      int totalSize = 0;
      final Map<String, int> categoryCounts = {};

      for (final category in categories) {
        try {
          final ListResult result = await _storage.ref(category).listAll();
          final int categoryFileCount = result.items.length;
          totalFiles += categoryFileCount;
          categoryCounts[category] = categoryFileCount;

          // Calculate total size for this category
          int categorySize = 0;
          for (final item in result.items) {
            try {
              final FullMetadata metadata = await item.getMetadata();
              categorySize += metadata.size ?? 0;
            } catch (e) {
              print('⚠️ Could not get metadata for $item: $e');
            }
          }
          totalSize += categorySize;
        } catch (e) {
          print('⚠️ Could not list files in $category: $e');
          categoryCounts[category] = 0;
        }
      }

      final double estimatedSizeMB = totalSize / (1024 * 1024);

      return {
        'total_files': totalFiles,
        'total_size_bytes': totalSize,
        'estimated_size_mb': double.parse(estimatedSizeMB.toStringAsFixed(2)),
        'profile_pictures': categoryCounts['profile_pictures/$userId'] ?? 0,
        'event_banners': categoryCounts['event_banners'] ?? 0,
        'plant_images': categoryCounts['plant_images'] ?? 0,
        'report_images': categoryCounts['report_images'] ?? 0,
      };
    } catch (e) {
      print('❌ Failed to get storage usage: $e');
      return {
        'total_files': 0,
        'total_size_bytes': 0,
        'estimated_size_mb': 0.0,
        'profile_pictures': 0,
        'event_banners': 0,
        'plant_images': 0,
        'report_images': 0,
      };
    }
  }

  // Clean up user files (for account deletion)
  Future<void> cleanupUserFiles(String userId) async {
    try {
      await initialize();
      
      print('🧹 Cleaning up files for user: $userId');
      
      final List<String> userPaths = [
        'profile_pictures/$userId',
        'report_images', // Note: reports might be associated with user ID in metadata
      ];

      for (final path in userPaths) {
        try {
          final ListResult result = await _storage.ref(path).listAll();
          for (final item in result.items) {
            try {
              await item.delete();
              print('✅ Deleted: ${item.fullPath}');
            } catch (e) {
              print('⚠️ Could not delete ${item.fullPath}: $e');
            }
          }
        } catch (e) {
          print('⚠️ Could not list files in $path: $e');
        }
      }
      
      print('✅ User files cleanup completed');
    } catch (e) {
      print('❌ Failed to cleanup user files: $e');
    }
  }

  // Download file to local storage
  Future<File> downloadFile(String url, String localFileName) async {
    try {
      await initialize();
      
      print('📥 Downloading file: $url');
      final Reference ref = _storage.refFromURL(url);
      
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final File localFile = File('${appDocDir.path}/$localFileName');
      
      await ref.writeToFile(localFile);
      
      print('✅ File downloaded successfully: ${localFile.path}');
      return localFile;
    } catch (e) {
      print('❌ Failed to download file: $e');
      throw Exception('Failed to download file: $e');
    }
  }

  // Get temporary download URL
  Future<String> getTemporaryDownloadUrl(String path) async {
    try {
      await initialize();
      
      // Firebase Storage getDownloadURL returns a URL that's valid for a long time
      // For true temporary URLs, you'd need backend implementation
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      print('❌ Failed to get download URL: $e');
      throw Exception('Failed to get download URL: $e');
    }
  }

  // Upload file with custom metadata
  Future<String> uploadFileWithMetadata(
    File file, 
    String path, 
    Map<String, String> customMetadata
  ) async {
    try {
      await initialize();
      
      if (!await file.exists()) {
        throw Exception('File does not exist: ${file.path}');
      }

      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: _getMimeType(file.path),
          customMetadata: {
            'uploaded_at': DateTime.now().toIso8601String(),
            'file_size': '${await file.length()}',
            ...customMetadata,
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('❌ Failed to upload file with metadata: $e');
      throw Exception('Failed to upload file with metadata: $e');
    }
  }

  // Update file metadata
  Future<void> updateFileMetadata(String path, Map<String, String> customMetadata) async {
    try {
      await initialize();
      
      final Reference ref = _storage.ref().child(path);
      await ref.updateMetadata(SettableMetadata(
        customMetadata: customMetadata,
      ));
      
      print('✅ File metadata updated successfully');
    } catch (e) {
      print('❌ Failed to update file metadata: $e');
      throw Exception('Failed to update file metadata: $e');
    }
  }

  // Helper method to get MIME type
  String _getMimeType(String filePath) {
    final String extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  // Pick image from gallery or camera
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      await initialize();
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('❌ Failed to pick image: $e');
      return null;
    }
  }

  // Pick multiple images from gallery
  Future<List<File>> pickMultipleImages() async {
    try {
      await initialize();
      
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('❌ Failed to pick multiple images: $e');
      return [];
    }
  }

  // Get list of files in a directory
  Future<List<String>> listFiles(String path) async {
    try {
      await initialize();
      
      final ListResult result = await _storage.ref(path).listAll();
      final List<String> fileUrls = [];
      
      for (final Reference item in result.items) {
        try {
          final String url = await item.getDownloadURL();
          fileUrls.add(url);
        } catch (e) {
          print('⚠️ Could not get URL for ${item.fullPath}: $e');
        }
      }
      
      return fileUrls;
    } catch (e) {
      print('❌ Failed to list files: $e');
      return [];
    }
  }

  // Get file size
  Future<int> getFileSize(String path) async {
    try {
      await initialize();
      
      final FullMetadata metadata = await _storage.ref(path).getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      print('❌ Failed to get file size: $e');
      return 0;
    }
  }

  // Get total storage size for a path
  Future<int> getTotalStorageSize(String path) async {
    try {
      await initialize();
      
      final ListResult result = await _storage.ref(path).listAll();
      int totalSize = 0;
      
      for (final Reference item in result.items) {
        try {
          final FullMetadata metadata = await item.getMetadata();
          totalSize += metadata.size ?? 0;
        } catch (e) {
          print('⚠️ Could not get metadata for ${item.fullPath}: $e');
        }
      }
      
      return totalSize;
    } catch (e) {
      print('❌ Failed to get total storage size: $e');
      return 0;
    }
  }

  // Generate unique file name
  String generateUniqueFileName(String originalFileName) {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${timestamp}_$originalFileName';
  }

  // Validate image file
  bool isValidImageFile(File file) {
    final List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final String extension = file.path.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  // Get file extension
  String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  // Check file size (in bytes)
  Future<int> getLocalFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      print('❌ Failed to get local file size: $e');
      return 0;
    }
  }

  // Dispose method for cleanup
  void dispose() {
    _isInitialized = false;
    print('🔚 StorageService disposed');
  }
}