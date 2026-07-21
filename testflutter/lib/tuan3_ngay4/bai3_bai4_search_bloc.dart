import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 3 + 4 — Bloc Transformer: restartable vs sequential
// Tuần 3 Ngày 4 (Chiều)
//
// Vấn đề: gõ "hoc flutter" → 10 request dồn dập
//   Response cũ về sau response mới → UI hiển thị kết quả sai
//
// restartable(): Event mới → HỦY Event cũ đang chạy → chỉ giữ mới nhất
// sequential(): Event mới → CHỜ Event cũ xong → có thể hiện kết quả sai
//
// Bài 3: dùng restartable() → kết quả luôn đúng
// Bài 4: đổi thành sequential() → quan sát kết quả sai/chậm
// ══════════════════════════════════════════════════════════════════

// ── Events ────────────────────────────────────────────────────────
abstract class SearchEvent {}

class TimKiemThayDoi extends SearchEvent {
  final String tuKhoa;
  final String transformer; // 'restartable' hoặc 'sequential'
  TimKiemThayDoi(this.tuKhoa, {this.transformer = 'restartable'});
}

// ── States ────────────────────────────────────────────────────────
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {
  final String tuKhoa;
  SearchLoading(this.tuKhoa);
}

class SearchLoaded extends SearchState {
  final List<Task> ketQua;
  final String tuKhoa;
  final int requestSo; // đếm để thấy request nào về sau
  SearchLoaded(this.ketQua, this.tuKhoa, this.requestSo);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

// ── Bloc dùng restartable() — Bài 3 ──────────────────────────────
class SearchBlocRestartable extends Bloc<SearchEvent, SearchState> {
  final ApiClient _api;
  int _requestCount = 0;

  SearchBlocRestartable(this._api) : super(SearchInitial()) {
    on<TimKiemThayDoi>(
      _onTimKiem,
      // restartable(): Event mới đến → HỦY Future đang chạy
      // Chỉ kết quả của Event cuối cùng được emit
      transformer: restartable(),
    );
  }

  Future<void> _onTimKiem(
      TimKiemThayDoi event, Emitter<SearchState> emit) async {
    if (event.tuKhoa.isEmpty) {
      emit(SearchInitial());
      return;
    }
    _requestCount++;
    final soNay = _requestCount;
    emit(SearchLoading(event.tuKhoa));

    try {
      // Giả lập network delay khác nhau để thấy race condition
      await Future.delayed(Duration(milliseconds: 200 + (soNay % 3) * 300));
      final tasks = await _api.timKiemTask(event.tuKhoa);
      // Với restartable(): nếu đã có Event mới → dòng này không chạy
      emit(SearchLoaded(tasks, event.tuKhoa, soNay));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}

// ── Bloc dùng sequential() — Bài 4 ───────────────────────────────
class SearchBlocSequential extends Bloc<SearchEvent, SearchState> {
  final ApiClient _api;
  int _requestCount = 0;

  SearchBlocSequential(this._api) : super(SearchInitial()) {
    on<TimKiemThayDoi>(
      _onTimKiem,
      // sequential() (mặc định): Event sau CHỜ Event trước xong
      // Gõ nhanh → phải chờ từng request xong → kết quả có thể sai thứ tự
      transformer: sequential(),
    );
  }

  Future<void> _onTimKiem(
      TimKiemThayDoi event, Emitter<SearchState> emit) async {
    if (event.tuKhoa.isEmpty) {
      emit(SearchInitial());
      return;
    }
    _requestCount++;
    final soNay = _requestCount;
    emit(SearchLoading(event.tuKhoa));

    try {
      await Future.delayed(Duration(milliseconds: 200 + (soNay % 3) * 300));
      final tasks = await _api.timKiemTask(event.tuKhoa);
      emit(SearchLoaded(tasks, event.tuKhoa, soNay));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
