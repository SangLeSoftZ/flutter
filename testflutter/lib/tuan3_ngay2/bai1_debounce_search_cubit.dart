import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1 — Debounce cho ô tìm kiếm Task
// Tuần 3 Ngày 2 (Sáng)
//
// Vấn đề không có debounce:
//   Gõ "học" (3 ký tự) → 3 request liên tiếp: "h", "hơ", "học"
//   Hầu hết bị lãng phí, response có thể về sai thứ tự
//
// Giải pháp Timer debounce:
//   Mỗi lần gõ → hủy timer cũ, đặt timer mới (400ms)
//   Chỉ khi ngừng gõ 400ms → timer kích hoạt → gọi API 1 lần
//
// Không dùng rxdart — tự viết bằng Timer (đủ cho 1 trường hợp)
// Dùng rxdart khi cần kết hợp nhiều operator Stream cùng lúc
// ══════════════════════════════════════════════════════════════════

// ── States ────────────────────────────────────────────────────────
abstract class DebounceSearchState {}

class DebounceSearchInitial extends DebounceSearchState {}

class DebounceSearchLoading extends DebounceSearchState {}

class DebounceSearchLoaded extends DebounceSearchState {
  final List<Task> ketQua;
  final String tuKhoa;
  final int soLanGoiApi; // đếm để demo debounce
  DebounceSearchLoaded(this.ketQua, this.tuKhoa, this.soLanGoiApi);
}

class DebounceSearchError extends DebounceSearchState {
  final String message;
  DebounceSearchError(this.message);
}

// ── Cubit ─────────────────────────────────────────────────────────
class DebounceSearchCubit extends Cubit<DebounceSearchState> {
  final ApiClient _api;
  Timer? _debounceTimer;
  int _soLanGoiApi = 0; // đếm số lần thực sự gọi API

  // Bài 2: đổi giá trị này về 0 để thấy gọi API dồn dập
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  DebounceSearchCubit(this._api) : super(DebounceSearchInitial());

  void onTuKhoaThayDoi(String tuKhoa) {
    // Hủy timer cũ nếu đang chạy (người dùng tiếp tục gõ)
    _debounceTimer?.cancel();

    if (tuKhoa.isEmpty) {
      emit(DebounceSearchInitial());
      return;
    }

    emit(DebounceSearchLoading());

    // Đặt timer mới — chỉ kích hoạt sau 400ms không có input mới
    _debounceTimer = Timer(_debounceDuration, () {
      _goiApi(tuKhoa);
    });
  }

  Future<void> _goiApi(String tuKhoa) async {
    _soLanGoiApi++;
    debugLog('API call #$_soLanGoiApi — tìm: "$tuKhoa"');

    try {
      final ketQua = await _api.timKiemTask(tuKhoa);
      emit(DebounceSearchLoaded(ketQua, tuKhoa, _soLanGoiApi));
    } catch (e) {
      emit(DebounceSearchError(e.toString()));
    }
  }

  // Log để quan sát debounce hoạt động
  void debugLog(String msg) {
    // ignore: avoid_print
    print('[Debounce] $msg');
  }

  @override
  Future<void> close() {
    // BẮT BUỘC cancel timer khi Cubit bị hủy — tránh memory leak
    _debounceTimer?.cancel();
    return super.close();
  }
}
