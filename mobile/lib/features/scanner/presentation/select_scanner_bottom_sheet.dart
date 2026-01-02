import 'package:flutter/material.dart';

class SelectScannerBottomSheet extends StatefulWidget {
  const SelectScannerBottomSheet({super.key});

  @override
  State<SelectScannerBottomSheet> createState() =>
      _SelectScannerBottomSheetState();
}

class _SelectScannerBottomSheetState
    extends State<SelectScannerBottomSheet> {
  String _selectedScanner = 'camera';
  bool _rememberChoice = false;

  void _confirmSelection() {
    Navigator.pop(context, {
      'type': _selectedScanner,
      'remember': _rememberChoice,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            // ===== HEADER =====
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Chọn phương thức quét",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // ===== OPTIONS =====
            _buildOption(
              title: "Camera",
              icon: Icons.camera_alt,
              value: 'camera',
            ),
            _buildOption(
              title: "Máy quét rời",
              icon: Icons.usb,
              value: 'hardware',
            ),

            // ===== REMEMBER =====
            SwitchListTile(
              value: _rememberChoice,
              onChanged: (value) {
                setState(() {
                  _rememberChoice = value;
                });
              },
              title: const Text("Ghi nhớ lựa chọn"),
            ),

            const SizedBox(height: 12),

            // ===== CONFIRM =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Xác nhận",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final bool isSelected = _selectedScanner == value;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.green : Colors.grey,
      ),
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        setState(() {
          _selectedScanner = value;
        });
      },
    );
  }
}
