import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// BAI 2 — file_picker: chon tai lieu PDF/DOC/XLSX
// Tuan 3 Ngay 9 Sang
//
// file_picker: tong quat hon image_picker
//   - Cho chon bat ky loai file nao tu he thong file cua thiet bi
//   - allowedExtensions: gioi han loai file duoc phep chon
//   - Khong co giao dien gallery dep nhu image_picker
//
// Tai sao can allowedExtensions?
//   Validate phia client: tranh chon nham file thuc thi (.exe, .apk)
//   VAN can validate them o server (vi client co the bi bypass qua Postman)

class Bai2FilePickerScreen extends StatefulWidget {
  const Bai2FilePickerScreen({super.key});

  @override
  State<Bai2FilePickerScreen> createState() => _Bai2FilePickerScreenState();
}

class _Bai2FilePickerScreenState extends State<Bai2FilePickerScreen> {
  File? _fileDaChon;
  String? _tenFile;
  String? _thongTinFile;
  bool _dangChon = false;
  String? _loiChon;

  Future<void> _chonTaiLieu() async {
    setState(() {
      _dangChon = true;
      _loiChon = null;
    });
    try {
      final ketQua = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx'],
        // withData: false (default) — chi lay path, du cho mobile
        // withData: true chi can cho web (khong co path tren web)
      );

      if (ketQua != null && ketQua.files.single.path != null) {
        final path = ketQua.files.single.path!;
        final file = File(path);
        final kichThuoc = await file.length();
        final ten = ketQua.files.single.name;
        final extension = ten.split('.').last.toLowerCase();

        setState(() {
          _fileDaChon = file;
          _tenFile = ten;
          _thongTinFile =
              'Ten: $ten\n'
              'Loai: ${extension.toUpperCase()}\n'
              'Kich thuoc: ${(kichThuoc / 1024).toStringAsFixed(1)} KB\n'
              'Duong dan: $path';
        });
      }
    } catch (e) {
      setState(() => _loiChon = 'Loi chon file: $e');
    } finally {
      setState(() => _dangChon = false);
    }
  }

  void _xoaFile() {
    setState(() {
      _fileDaChon = null;
      _tenFile = null;
      _thongTinFile = null;
      _loiChon = null;
    });
  }

  IconData _layIconTheoLoai(String? ten) {
    if (ten == null) return Icons.insert_drive_file;
    final ext = ten.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xlsx':
      case 'xls':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _layMauTheoLoai(String? ten) {
    if (ten == null) return Colors.grey;
    final ext = ten.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Colors.red.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade600;
      case 'xlsx':
      case 'xls':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('T3N9 Bai 2 — file_picker'),
        backgroundColor: Colors.teal.shade700,
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
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: const Text(
                'Bai 2: file_picker\n'
                '• Chon tai lieu: PDF, DOC, DOCX, XLSX\n'
                '• allowedExtensions: gioi han loai file\n'
                '• Hien thi ten + loai + kich thuoc file\n'
                '• Khac image_picker: khong co giao dien gallery',
                style: TextStyle(fontSize: 12, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 16),

            // Vung hien thi file da chon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _fileDaChon != null
                          ? Colors.teal.shade400
                          : Colors.grey.shade300,
                  width: _fileDaChon != null ? 2 : 1,
                ),
              ),
              child:
                  _fileDaChon != null
                      ? Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _layMauTheoLoai(_tenFile).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _layIconTheoLoai(_tenFile),
                              size: 32,
                              color: _layMauTheoLoai(_tenFile),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tenFile ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _thongTinFile?.split('\n')[2] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.grey,
                            onPressed: _xoaFile,
                          ),
                        ],
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chua chon tai lieu',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cho phep: PDF, DOC, DOCX, XLSX',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
            ),

            // Chi tiet thong tin file
            if (_thongTinFile != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Text(
                  _thongTinFile!,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Colors.teal.shade800,
                  ),
                ),
              ),
            ],

            // Thong bao loi
            if (_loiChon != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _loiChon!,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Nut chon file
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _dangChon ? null : _chonTaiLieu,
                icon:
                    _dangChon
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.attach_file, size: 18),
                label: Text(
                  _dangChon ? 'Dang chon...' : 'Chon tai lieu (PDF/DOC/XLSX)',
                ),
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
                '• allowedExtensions: validate phia CLIENT (co the bypass)\n'
                '• VAN can validate them o SERVER (kiem tra MIME type, kich thuoc)\n'
                '• FileType.custom + allowedExtensions = chi hien file dung loai trong picker\n'
                '• withData: false (mac dinh) = lay path, du cho mobile\n'
                '• withData: true = doc byte ngay, can cho web (khong co path)',
                style: TextStyle(fontSize: 11, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
