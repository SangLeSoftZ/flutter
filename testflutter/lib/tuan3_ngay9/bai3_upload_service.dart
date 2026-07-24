import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// BAI 3 — TaskFileUploadService: upload file bang Dio multipart
// Tuan 3 Ngay 9 Chieu
//
// Tai sao dung multipart thay vi JSON?
//   JSON: chi truyen text, file phai encode Base64 (phong to ~33%, khong chuan)
//   multipart/form-data: tieu chuan HTTP cho file, vua co phan text vua co phan binary
//
// MultipartFile.fromFile doc file theo STREAM (khong load het vao RAM)
//   -> an toan voi file lon (video, PDF nhieu trang)
//
// onSendProgress: Dio goi callback nhieu lan trong luc upload
//   -> so lieu thuc te tu tang network, khong phai uoc luong
//
// Dio Upload RIENG voi sendTimeout dai hon:
//   API JSON: vai tram ms -> timeout 10s la du
//   Upload file: co the mat hang chuc giay tren mang cham -> can timeout lon hon

class TaskFileUploadService {
  // Dio RIENG cho upload — sendTimeout dai hon Dio chinh
  // Khong dung Dio co AuthInterceptor de tranh conflict voi Content-Type
  static Dio taoDioUpload() {
    return Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8080',
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 120),    // 2 phut cho file lon
        receiveTimeout: const Duration(seconds: 30),
        // KHONG set Content-Type o day — Dio tu set multipart/form-data + boundary
      ),
    );
  }

  final Dio _dio;

  TaskFileUploadService({Dio? dio}) : _dio = dio ?? taoDioUpload();

  /// Upload file len server, tra ve duong dan da luu
  ///
  /// [file]      : File can upload (anh hoac PDF)
  /// [taskId]    : ID cua Task dinh kem
  /// [onTienDo]  : Callback tien do 0.0 -> 1.0, Dio goi nhieu lan trong luc upload
  Future<String> uploadFile({
    required File file,
    required int taskId,
    void Function(double phanTram)? onTienDo,
  }) async {
    final tenFile = file.path.split('/').last.split('\\').last;

    debugPrint('[Upload] Bat dau upload: $tenFile, taskId: $taskId');
    debugPrint('[Upload] Kich thuoc: ${(await file.length() / 1024).toStringAsFixed(1)} KB');

    // FormData: chua ca phan text (taskId) va phan binary (file)
    // -> Dio tu dong set Content-Type: multipart/form-data; boundary=...
    final formData = FormData.fromMap({
      'taskId': taskId,        // phan TEXT gui kem file
      'file': await MultipartFile.fromFile(
        file.path,
        filename: tenFile,     // giu dung ten + duoi file goc
        // Dio tu detect Content-Type dua theo duoi file:
        //   .jpg/.jpeg -> image/jpeg
        //   .png       -> image/png
        //   .pdf       -> application/pdf
      ),
    });

    debugPrint('[Upload] FormData da tao, bat dau gui request...');

    final response = await _dio.post(
      '/api/tasks/upload',
      data: formData,
      onSendProgress: (soByteDaGui, tongSoByte) {
        // Dio goi callback nay nhieu lan trong luc upload
        // soByteDaGui: so byte da truyen qua mang (thuc te, khong phai uoc luong)
        // tongSoByte : tong kich thuoc FormData
        if (tongSoByte > 0) {
          final phanTram = soByteDaGui / tongSoByte;
          debugPrint('[Upload] Tien do: ${(phanTram * 100).toStringAsFixed(0)}%'
              ' ($soByteDaGui/$tongSoByte bytes)');
          onTienDo?.call(phanTram);
        }
      },
    );

    final duongDanFile = response.data['duongDanFile'] as String;
    debugPrint('[Upload] THANH CONG! Duong dan: $duongDanFile');
    return duongDanFile;
  }
}
