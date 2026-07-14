import 'package:flutter_bloc/flutter_bloc.dart';

/// BlocObserver toàn cục — theo dõi mọi Cubit/Bloc trong app
/// Đăng ký 1 lần trong main() là xong, không cần sửa từng Cubit
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('[Observer] Tạo mới: ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // onChange chạy cho cả Cubit lẫn Bloc
    print('[Observer] ${bloc.runtimeType} đổi state:\n'
        '  cũ: ${change.currentState}\n'
        '  mới: ${change.nextState}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // onTransition chỉ chạy với Bloc (có Event) — không chạy với Cubit
    print('[Observer] ${bloc.runtimeType} nhận Event: ${transition.event}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('[Observer] Lỗi trong ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('[Observer] Đóng: ${bloc.runtimeType}');
  }
}
