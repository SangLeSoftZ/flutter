import 'package:hydrated_bloc/hydrated_bloc.dart';

/// ThemeCubit dùng HydratedCubit — tự động lưu/khôi phục state khi tắt app
/// Chỉ đổi 2 điểm so với Cubit thường:
///   1. Kế thừa HydratedCubit thay vì Cubit
///   2. Thêm fromJson / toJson
/// Logic toggle() và cách dùng ở UI không đổi gì cả
class ThemeCubit extends HydratedCubit<bool> {
  ThemeCubit() : super(false); // false = Light mode

  void toggle() => emit(!state);

  // HydratedCubit tự gọi toJson() mỗi khi emit() — lưu xuống đĩa
  @override
  Map<String, dynamic> toJson(bool state) => {'darkMode': state};

  // HydratedCubit tự gọi fromJson() lúc app khởi động — khôi phục state
  @override
  bool fromJson(Map<String, dynamic> json) => json['darkMode'] as bool;
}
