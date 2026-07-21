import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../login/injection_container.dart';
import '../login/domain/usecases/login_usecase.dart';
import '../login/data/datasources/auth_local_datasource.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 5 — droppable(): tránh submit trùng
// Tuần 3 Ngày 4 (Chiều)
//
// droppable(): đang xử lý Event → BỎ QUA mọi Event mới
// Dùng cho nút Submit/Login: bấm nhiều lần → chỉ xử lý lần đầu
//
// Không dùng droppable():
//   Bấm Login 3 lần → 3 request song song → 3 lần lưu token
//
// Có droppable():
//   Bấm Login 3 lần → chỉ request đầu được xử lý → an toàn
// ══════════════════════════════════════════════════════════════════

// ── Events ────────────────────────────────────────────────────────
abstract class LoginTransformerEvent {}

class NhanDangNhap extends LoginTransformerEvent {
  final String username;
  final String password;
  NhanDangNhap(this.username, this.password);
}

class DangXuat extends LoginTransformerEvent {}

// ── States ────────────────────────────────────────────────────────
abstract class LoginTransformerState {}

class LoginTransformerInitial extends LoginTransformerState {}

class LoginTransformerLoading extends LoginTransformerState {
  final int lanBam; // đếm số lần bấm để demo droppable
  LoginTransformerLoading(this.lanBam);
}

class LoginTransformerSuccess extends LoginTransformerState {
  final String username;
  final int soRequestThucSu; // xác nhận chỉ 1 request được xử lý
  LoginTransformerSuccess(this.username, this.soRequestThucSu);
}

class LoginTransformerError extends LoginTransformerState {
  final String message;
  LoginTransformerError(this.message);
}

// ── Bloc dùng droppable() ─────────────────────────────────────────
class LoginTransformerBloc
    extends Bloc<LoginTransformerEvent, LoginTransformerState> {
  int _soLanBam = 0;
  int _soRequestThucSu = 0;

  LoginTransformerBloc() : super(LoginTransformerInitial()) {
    on<NhanDangNhap>(
      _onDangNhap,
      // droppable(): đang xử lý → BỎ QUA Event mới
      // Bấm Login 5 lần → chỉ lần đầu được xử lý
      transformer: droppable(),
    );
    on<DangXuat>(_onDangXuat);
  }

  Future<void> _onDangNhap(
      NhanDangNhap event, Emitter<LoginTransformerState> emit) async {
    _soLanBam++;
    _soRequestThucSu++;
    final soNay = _soRequestThucSu;

    emit(LoginTransformerLoading(_soLanBam));
    // ignore: avoid_print
    print('[droppable] Bắt đầu xử lý request #$soNay (username: ${event.username})');

    try {
      final loginUseCase = getIt<LoginUseCase>();
      final (user, failure) = await loginUseCase(
        LoginParams(username: event.username, password: event.password),
      );

      if (failure != null) {
        emit(LoginTransformerError(failure.message));
        return;
      }

      final authLocal = AuthLocalDataSource();
      await authLocal.saveAuthInfo(
        token: user!.token,
        username: user.username,
        role: user.role,
        userId: user.id,
      );

      // ignore: avoid_print
      print('[droppable] Request #$soNay hoàn thành');
      emit(LoginTransformerSuccess(user.username, soNay));
    } catch (e) {
      emit(LoginTransformerError(e.toString()));
    }
  }

  Future<void> _onDangXuat(
      DangXuat event, Emitter<LoginTransformerState> emit) async {
    _soLanBam = 0;
    _soRequestThucSu = 0;
    await AuthLocalDataSource().clearAuthInfo();
    emit(LoginTransformerInitial());
  }
}
