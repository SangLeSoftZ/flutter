import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'bai3_upload_service.dart';

// BAI 4+5 — Upload Screen: LinearProgressIndicator + xu ly loi
// Tuan 3 Ngay 9 Chieu
//
// BAI 4: LinearProgressIndicator(value: _tienDo)
//   - value: 0.0 -> 1.0, cap nhat theo thoi gian thuc tu onSendProgress
//   - Khac CircularProgressIndicator(): khong co value = xoay vo han, khong biet bao gio xong
//   - Voi upload file, Dio biet chinh xac so byte da gui -> dung gia tri cu the
//
// BAI 5: Xu ly 2 loai loi cu the
//   - connectionTimeout/receiveTimeout: mat mang giua chung -> goi y thu lai
//   - 413 Payload Too Large: file qua lon -> thong bao gioi han + goi y chon file nho hon
//   - Cac loi khac: hien thong bao chung

class Bai4Bai5UploadScreen extends StatefulWidget {
  const Bai4Bai5UploadScreen({super.key});

  @override
  State<Bai4Bai5UploadScreen> createState() => _Bai4Bai5UploadScreenState();
}

class _Bai4Bai5UploadScreenState extends State<Bai4Bai5UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final TaskFileUploadService _uploadService = TaskFileUploadService();

  File? _fileDaChon;
  String? _tenFile;
  int? _kichThuocKB;

  // BAI 4: tien do upload
  double _tienDo = 0;
  bool _dangUpload = false;

  // Ket qua / loi
  String? _duongDanFile;   // upload thanh cong
  String? _loiUpload;      // thong bao loi

  // Chon anh tu gallery
  Future<void> _chonAnh() async {
    final XFile? anh = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (anh != null) {
      final file = File(anh.path);
      final kb = (await file.length()) ~/ 1024;
      setState(() {
        _fileDaChon = file;
        _tenFile = anh.name;
        _kichThuocKB = kb;
        _duongDanFile = null;
        _loiUpload = null;
        _tienDo = 0;
      });
    }
  }

  // BAT DAU UPLOAD
  Future<void> _batDauUpload() async {
    if (_fileDaChon == null) return;

    setState(() {
      _dangUpload = true;
      _tienDo = 0;
      _duongDanFile = null;
      _loiUpload = null;
    });

    try {
      final duongDan = await _uploadService.uploadFile(
        file: _fileDaChon!,
        taskId: 1, // demo voi task ID = 1
        onTienDo: (phanTram) {
          // BAI 4: cap nhat UI theo thoi gian thuc
          // setState trong callback cua Dio — chay tren main thread
          setState(() => _tienDo = phanTram);
        },
      );
      setState(() => _duongDanFile = duongDan);

    // BAI 5: xu ly loi cu the
    } on DioException catch (e) {
      setState(() => _loiUpload = _xuLyLoiDio(e));
    } catch (e) {
      setState(() => _loiUpload = 'Loi khong xac dinh: $e');
    } finally {
      setState(() => _dangUpload = false);
    }
  }

  // BAI 5: Phan tich loai loi DioException -> thong bao phu hop
  String _xuLyLoiDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Mat mang giua chung hoac qua thoi gian cho
        return '⏱ Mat ket noi trong luc upload.\n'
            'Kiem tra mang va thu lai — file chua duoc luu tren server.';

      case DioExceptionType.connectionError:
        return '📡 Khong the ket noi den server.\n'
            'Kiem tra Spring Boot da chay chua (port 8080).';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 413) {
          // 413 Payload Too Large
          return '📦 File qua lon (vuot gioi han 10MB).\n'
              'Chon anh nho hon hoac dung imageQuality thap hon.';
        } else if (statusCode == 400) {
          final msg = e.response?.data?['error'] ?? 'Du lieu khong hop le';
          return '❌ Server tu choi: $msg';
        } else if (statusCode == 401) {
          return '🔒 Chua dang nhap hoac token het han.\n'
              'Vao Quick Login de dang nhap lai.';
        } else {
          return '🚫 Loi server: HTTP $statusCode\n'
              '${e.response?.data?['error'] ?? e.message}';
        }

      case DioExceptionType.cancel:
        return '🚫 Upload bi huy.';

      default:
        return '❓ Loi: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('T3N9 Bai 4+5 — Upload + Tien Do'),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mo ta
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepOrange.shade200),
              ),
              child: const Text(
                'Bai 4: LinearProgressIndicator theo thoi gian thuc\n'
                'Bai 5: Xu ly loi mat mang (timeout) + file qua lon (413)\n'
                'Kiem tra terminal: [Upload] log tien do tung phan tram',
                style: TextStyle(fontSize: 12, color: Colors.deepOrange),
              ),
            ),

            const SizedBox(height: 16),

            // Vung chon file
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  if (_fileDaChon != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _fileDaChon!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_tenFile  •  $_kichThuocKB KB',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ] else ...[
                    Icon(Icons.cloud_upload_outlined,
                        size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text('Chua chon anh',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _dangUpload ? null : _chonAnh,
                    icon: const Icon(Icons.photo_library, size: 16),
                    label: Text(_fileDaChon != null ? 'Doi anh' : 'Chon anh'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // BAI 4: Thanh tien do
            if (_dangUpload) ...[
              Row(
                children: [
                  const Icon(Icons.upload, size: 16, color: Colors.deepOrange),
                  const SizedBox(width: 6),
                  Text(
                    'Dang upload... ${(_tienDo * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // LinearProgressIndicator voi value cu the — KHONG phai xoay vo han
              // value: 0.0 (0%) -> 1.0 (100%), cap nhat lien tuc tu onSendProgress
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _tienDo,
                  minHeight: 10,
                  backgroundColor: Colors.deepOrange.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepOrange.shade700),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Nut upload
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed:
                    (_fileDaChon != null && !_dangUpload) ? _batDauUpload : null,
                icon: _dangUpload
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload, size: 18),
                label: Text(_dangUpload ? 'Dang upload...' : 'Tai len server'),
              ),
            ),

            const SizedBox(height: 16),

            // Ket qua thanh cong
            if (_duongDanFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upload thanh cong!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700)),
                          const SizedBox(height: 2),
                          Text(
                            _duongDanFile!,
                            style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: Colors.green.shade800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // BAI 5: Thong bao loi cu the
            if (_loiUpload != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _loiUpload!,
                        style: TextStyle(
                            fontSize: 13, color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
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
                '• multipart/form-data: vua gui file binary vua gui text (taskId)\n'
                '• MultipartFile.fromFile: doc theo stream, khong load het RAM\n'
                '• onSendProgress: so lieu thuc te tu tang network\n'
                '• LinearProgressIndicator(value: x): khac CircularProgressIndicator()\n'
                '• Timeout upload > timeout API JSON (file lon = can nhieu thoi gian)\n'
                '• 413 Payload Too Large: server gioi han kich thuoc file',
                style: TextStyle(fontSize: 11, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
