import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// BAI 1 — image_picker: chon anh tu gallery hoac camera
// Tuan 3 Ngay 9 Sang
//
// image_picker: chuyen biet cho anh/video
//   - Dung giao dien Photo Picker cua he dieu hanh (quen thuoc voi nguoi dung)
//   - imageQuality: nen anh giam dung luong truoc khi upload
//   - maxWidth: gioi han kich thuoc anh, tranh anh qua lon
//
// So sanh voi file_picker:
//   image_picker -> gallery dep, co nut chup camera tich hop
//   file_picker  -> browser file thong thuong, dung cho PDF/DOC/XLSX

class Bai1ImagePickerScreen extends StatefulWidget {
  const Bai1ImagePickerScreen({super.key});

  @override
  State<Bai1ImagePickerScreen> createState() => _Bai1ImagePickerScreenState();
}

class _Bai1ImagePickerScreenState extends State<Bai1ImagePickerScreen> {
  final _picker = ImagePicker();
  File? _anhDaChon;
  String? _thongTinAnh; // ten file + kich thuoc
  bool _dangChon = false;

  // Chon anh tu thu vien (gallery)
  Future<void> _chonTuThuVien() async {
    setState(() => _dangChon = true);
    try {
      final XFile? anh = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality:
            80, // NEN xuong 80% — giam dung luong ma mat bien kha nang hien thi
        maxWidth: 1280, // Gioi han chieu rong — du net ma khong qua nang
      );
      if (anh != null) {
        final file = File(anh.path);
        final kichThuoc = await file.length();
        setState(() {
          _anhDaChon = file;
          _thongTinAnh =
              'Ten: ${anh.name}\nKich thuoc: ${(kichThuoc / 1024).toStringAsFixed(1)} KB';
        });
      }
    } finally {
      setState(() => _dangChon = false);
    }
  }

  // Chup anh truc tiep tu camera
  Future<void> _chupTuCamera() async {
    setState(() => _dangChon = true);
    try {
      final XFile? anh = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (anh != null) {
        final file = File(anh.path);
        final kichThuoc = await file.length();
        setState(() {
          _anhDaChon = file;
          _thongTinAnh =
              'Ten: ${anh.name}\nKich thuoc: ${(kichThuoc / 1024).toStringAsFixed(1)} KB';
        });
      }
    } finally {
      setState(() => _dangChon = false);
    }
  }

  void _xoaAnh() {
    setState(() {
      _anhDaChon = null;
      _thongTinAnh = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('T3N9 Bai 1 — image_picker'),
        backgroundColor: Colors.deepPurple.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mo ta bai hoc
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: const Text(
                'Bai 1: image_picker\n'
                '• Chon anh tu gallery (co nen chat luong)\n'
                '• Chup anh truc tiep tu camera\n'
                '• Hien thi preview + thong tin file\n'
                '• imageQuality: 80, maxWidth: 1280',
                style: TextStyle(fontSize: 12, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 16),

            // Vung preview anh
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _anhDaChon != null
                          ? Colors.deepPurple.shade400
                          : Colors.grey.shade300,
                  width: _anhDaChon != null ? 2 : 1,
                ),
              ),
              child:
                  _anhDaChon != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_anhDaChon!, fit: BoxFit.cover),
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chua chon anh',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
            ),

            // Thong tin anh
            if (_thongTinAnh != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  _thongTinAnh!,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Cac nut chon
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                  ),
                  onPressed: _dangChon ? null : _chonTuThuVien,
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Chon tu Gallery'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                  ),
                  onPressed: _dangChon ? null : _chupTuCamera,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Chup Camera'),
                ),
                if (_anhDaChon != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                    ),
                    onPressed: _xoaAnh,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Xoa anh'),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Ghi chu kien thuc
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Text(
                'Kien thuc:\n'
                '• imageQuality: 80 = giam ~60-70% dung luong, mat bien kha nang hien thi\n'
                '• maxWidth: 1280 = du net cho man hinh Full HD\n'
                '• Nen anh ngay khi chon, TRUOC khi upload — hieu qua hon nen sau\n'
                '• Bai 2: file_picker de chon PDF/DOC (khong co gallery dep)',
                style: TextStyle(fontSize: 11, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
