import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

// BAI 1 — BiometricService: kiem tra ho tro + xac thuc sinh trac hoc
// Tuan 4 Ngay 1 Sang
//
// QUAN TRONG: local_auth KHONG gui van tay/khuon mat len server
//   - Xac thuc dien ra cuc bo tren chip bao mat cua thiet bi
//   - Ket qua chi la true/false
//   - Dung de "mo khoa" token da luu san trong SecureStorage
//
// isDeviceSupported(): phan cung co cam bien van tay/Face ID khong?
// canCheckBiometrics: nguoi dung da dang ky van tay/Face ID chua?
//   -> Can ca 2 dieu kien moi hien nut sinh trac hoc

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Kiem tra thiet bi co ho tro sinh trac hoc day du khong
  // LUU Y: tren emulator, isDeviceSupported() thuong tra false du van tay da dang ky
  // -> dung canCheckBiometrics la dieu kien chinh, isDeviceSupported la phu
  Future<bool> thietBiCoHoTro() async {
    try {
      final coTheKiemTra = await _auth.isDeviceSupported();
      final coSinhTracHoc = await _auth.canCheckBiometrics;
      debugPrint('[Biometric] isDeviceSupported: $coTheKiemTra');
      debugPrint('[Biometric] canCheckBiometrics: $coSinhTracHoc');
      // canCheckBiometrics: nguoi dung DA DANG KY van tay -> day la dieu kien quan trong nhat
      // isDeviceSupported: tren emulator thuong false du thuc te van hoat dong
      // -> ho tro neu MOT TRONG HAI la true
      return coSinhTracHoc || coTheKiemTra;
    } on PlatformException catch (e) {
      debugPrint('[Biometric] Loi kiem tra ho tro: ${e.code} - ${e.message}');
      return false;
    }
  }

  // Lay danh sach loai sinh trac hoc thiet bi ho tro
  // VD: [BiometricType.fingerprint, BiometricType.face]
  Future<List<BiometricType>> layDanhSachLoaiHoTro() async {
    try {
      final danhSach = await _auth.getAvailableBiometrics();
      debugPrint('[Biometric] Cac loai ho tro: $danhSach');
      return danhSach;
    } on PlatformException catch (e) {
      debugPrint('[Biometric] Loi lay danh sach: ${e.code}');
      return [];
    }
  }

  // Hien hop thoai xac thuc sinh trac hoc
  // Tra ve true = xac thuc thanh cong
  // Tra ve false = that bai / huy bo
  Future<KetQuaXacThuc> xacThucSinhTracHoc() async {
    try {
      final ketQua = await _auth.authenticate(
        localizedReason: 'Xác thực để đăng nhập vào ứng dụng',
        options: const AuthenticationOptions(
          biometricOnly: true, // CHI sinh trac hoc, KHONG fallback PIN thiet bi
          // stickyAuth: giu luong xac thuc neu app bi chuyen xuong nen
          // (VD co thong bao goi den giua chung)
          stickyAuth: true,
        ),
      );
      debugPrint('[Biometric] Ket qua xac thuc: $ketQua');
      return ketQua ? KetQuaXacThuc.thanhCong : KetQuaXacThuc.thatBai;
    } on PlatformException catch (e) {
      debugPrint('[Biometric] Loi xac thuc: ${e.code} - ${e.message}');
      // Xu ly tung ma loi cu the
      switch (e.code) {
        case 'NotEnrolled':
          return KetQuaXacThuc.chuaDangKy;
        case 'LockedOut':
          return KetQuaXacThuc.tamKhoa;
        case 'PermanentlyLockedOut':
          return KetQuaXacThuc.khoaVinh;
        case 'NotAvailable':
          // "Security credentials not available" = chua cai PIN/Pattern
          // Android bat buoc phai co man hinh khoa truoc khi dung sinh trac hoc
          return KetQuaXacThuc.chuaPIN;
        default:
          return KetQuaXacThuc.loiKhac;
      }
    }
  }

  // Chuyen BiometricType thanh ten hien thi
  String tenLoaiSinhTracHoc(BiometricType loai) {
    switch (loai) {
      case BiometricType.fingerprint:
        return 'Vân tay';
      case BiometricType.face:
        return 'Khuôn mặt (Face ID)';
      case BiometricType.iris:
        return 'Mống mắt';
      case BiometricType.strong:
        return 'Sinh trắc học mạnh';
      case BiometricType.weak:
        return 'Sinh trắc học yếu';
    }
  }
}

// Ket qua xac thuc — ro rang hon bool
enum KetQuaXacThuc {
  thanhCong, // xac thuc thanh cong
  thatBai, // sai van tay / huy bo
  chuaDangKy, // NotEnrolled: chua cai dat van tay trong he thong
  tamKhoa, // LockedOut: sai qua nhieu lan, cho vai chuc giay
  khoaVinh, // PermanentlyLockedOut (Android): can nhap PIN truoc
  khongHoTro, // NotAvailable: thiet bi khong ho tro
  chuaPIN, // NotAvailable "Security credentials": chua cai PIN/Pattern man hinh khoa
  loiKhac, // loi khac khong xac dinh
}
