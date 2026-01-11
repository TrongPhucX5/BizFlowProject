import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _idFront;
  File? _idBack;
  File? _selfie;

  Future<void> _pickImage(Function(File) onPicked) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      onPicked(File(image.path));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực KYC'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _kycCard(
            title: 'CCCD - Mặt trước',
            file: _idFront,
            onTap: () => _pickImage((f) => _idFront = f),
          ),
          const SizedBox(height: 16),

          _kycCard(
            title: 'CCCD - Mặt sau',
            file: _idBack,
            onTap: () => _pickImage((f) => _idBack = f),
          ),
          const SizedBox(height: 16),

          _kycCard(
            title: 'Xác thực khuôn mặt',
            subtitle: 'Chụp ảnh selfie',
            file: _selfie,
            onTap: () => _pickImage((f) => _selfie = f),
          ),

          const SizedBox(height: 30),
          _submitButton(),
        ],
      ),
    );
  }

  Widget _kycCard({
    required String title,
    String? subtitle,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            _previewImage(file),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(
                    file == null ? 'Chưa chụp' : 'Đã chụp',
                    style: TextStyle(
                      color: file == null ? Colors.red : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.camera_alt, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _previewImage(File? file) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
        image: file != null
            ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
            : null,
      ),
      child: file == null
          ? const Icon(Icons.photo, color: Colors.grey)
          : null,
    );
  }

  Widget _submitButton() {
    final isReady = _idFront != null && _idBack != null && _selfie != null;

    return ElevatedButton(
      onPressed: isReady
          ? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi hồ sơ KYC')),
        );
      }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text('Gửi xác thực'),
    );
  }
}
