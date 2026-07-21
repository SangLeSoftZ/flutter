# HƯỚNG DẪN TEST FLUTTER - ĐẦY ĐỦ VÀ CHI TIẾT

## 📚 MỤC LỤC
1. [Tổng quan về Testing trong Flutter](#1-tổng-quan)
2. [Các loại Test](#2-các-loại-test)
3. [Cài đặt và Cấu hình](#3-cài-đặt-và-cấu-hình)
4. [Unit Test](#4-unit-test)
5. [Widget Test](#5-widget-test)
6. [Bloc Test](#6-bloc-test)
7. [Integration Test](#7-integration-test)
8. [Mocking với Mocktail](#8-mocking-với-mocktail)
9. [Best Practices](#9-best-practices)
10. [Chạy Tests](#10-chạy-tests)

---

## 1. TỔNG QUAN

### Testing là gì?
Testing là quá trình kiểm tra code của bạn hoạt động đúng như mong đợi. Trong Flutter, có 3 loại test chính:

- **Unit Test**: Test các hàm, class, model riêng lẻ
- **Widget Test**: Test UI components và tương tác
- **Integration Test**: Test toàn bộ ứng dụng end-to-end

### Tại sao cần Test?
✅ Phát hiện lỗi sớm  
✅ Đảm bảo code hoạt động đúng  
✅ Dễ dàng refactor code  
✅ Tự động hóa kiểm thử  
✅ Tài liệu sống cho code  

---

## 2. CÁC LOẠI TEST

### 2.1 Unit Test
- Test các hàm, method, class độc lập
- Nhanh, dễ viết, dễ maintain
- Không test UI

### 2.2 Widget Test
- Test UI components
- Test tương tác người dùng (tap, scroll, input)
- Chạy trong môi trường test (không cần device/emulator)

### 2.3 Integration Test
- Test toàn bộ ứng dụng
- Test flow thực tế
- Chạy trên device/emulator thật

---

## 3. CÀI ĐẶT VÀ CẤU HÌNH

### Dependencies đã có trong project:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7      # Test BLoC/Cubit
  mocktail: ^1.0.4       # Mock dependencies
```

### Cấu trúc thư mục:
```
testflutter/
├── lib/                 # Source code
├── test/               # Unit & Widget tests
│   ├── unit/
│   ├── widget/
│   └── bloc/
└── integration_test/   # Integration tests
```

---

## 4. UNIT TEST

### 4.1 Test Model/Class đơn giản

**Ví dụ: Test UserModel**

```dart
// File: test/unit/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:testflutter/login/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel should create instance correctly', () {
      // Arrange
      final user = UserModel(
        id: '1',
        username: 'testuser',
        email: 'test@example.com',
      );

      // Assert
      expect(user.id, '1');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
    });

    test('UserModel toJson should convert to map', () {
      // Arrange
      final user = UserModel(
        id: '1',
        username: 'testuser',
        email: 'test@example.com',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
    });

    test('UserModel fromJson should create from map', () {
      // Arrange
      final json = {
        'id': '1',
        'username': 'testuser',
        'email': 'test@example.com',
      };

      // Act
      final user = UserModel.fromJson(json);

      // Assert
      expect(user.id, '1');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
    });
  });
}
```

### 4.2 Test Business Logic

```dart
// File: test/unit/calculator_test.dart
import 'package:flutter_test/flutter_test.dart';

class Calculator {
  int add(int a, int b) => a + b;
  int subtract(int a, int b) => a - b;
  double divide(int a, int b) {
    if (b == 0) throw ArgumentError('Cannot divide by zero');
    return a / b;
  }
}

void main() {
  late Calculator calculator;

  // setUp chạy trước mỗi test
  setUp(() {
    calculator = Calculator();
  });

  group('Calculator Tests', () {
    test('should add two numbers', () {
      expect(calculator.add(2, 3), 5);
      expect(calculator.add(-1, 1), 0);
    });

    test('should subtract two numbers', () {
      expect(calculator.subtract(5, 3), 2);
      expect(calculator.subtract(3, 5), -2);
    });

    test('should divide two numbers', () {
      expect(calculator.divide(10, 2), 5.0);
      expect(calculator.divide(7, 2), 3.5);
    });

    test('should throw error when dividing by zero', () {
      expect(
        () => calculator.divide(5, 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

### 4.3 Test với Async/Await

```dart
// File: test/unit/async_test.dart
import 'package:flutter_test/flutter_test.dart';

Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 1));
  return 'Data loaded';
}

void main() {
  test('should fetch data asynchronously', () async {
    // Act
    final result = await fetchData();

    // Assert
    expect(result, 'Data loaded');
  });

  test('should handle async errors', () async {
    Future<void> errorFunction() async {
      throw Exception('Network error');
    }

    expect(
      () => errorFunction(),
      throwsA(isA<Exception>()),
    );
  });
}
```

---

## 5. WIDGET TEST

### 5.1 Test Widget đơn giản

```dart
// File: test/widget/simple_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Should display text widget', (WidgetTester tester) async {
    // Arrange & Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Text('Hello Flutter'),
        ),
      ),
    );

    // Assert
    expect(find.text('Hello Flutter'), findsOneWidget);
    expect(find.text('Not Found'), findsNothing);
  });

  testWidgets('Should display button and respond to tap', 
    (WidgetTester tester) async {
    int counter = 0;

    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Counter: $counter'),
              ElevatedButton(
                onPressed: () => counter++,
                child: Text('Increment'),
              ),
            ],
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Trigger rebuild

    // Assert
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
```

### 5.2 Test Form và Input

```dart
// File: test/widget/login_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _login() {
    if (_usernameController.text.isEmpty) {
      setState(() => _errorMessage = 'Username required');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'Password too short');
      return;
    }
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          key: Key('username_field'),
          controller: _usernameController,
          decoration: InputDecoration(labelText: 'Username'),
        ),
        TextField(
          key: Key('password_field'),
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        if (_errorMessage != null)
          Text(_errorMessage!, style: TextStyle(color: Colors.red)),
        ElevatedButton(
          key: Key('login_button'),
          onPressed: _login,
          child: Text('Login'),
        ),
      ],
    );
  }
}

void main() {
  testWidgets('Should show error when username is empty', 
    (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LoginForm())));

    // Act
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pump();

    // Assert
    expect(find.text('Username required'), findsOneWidget);
  });

  testWidgets('Should show error when password is too short', 
    (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LoginForm())));

    // Act
    await tester.enterText(find.byKey(Key('username_field')), 'testuser');
    await tester.enterText(find.byKey(Key('password_field')), '123');
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pump();

    // Assert
    expect(find.text('Password too short'), findsOneWidget);
  });

  testWidgets('Should login successfully with valid credentials', 
    (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LoginForm())));

    // Act
    await tester.enterText(find.byKey(Key('username_field')), 'testuser');
    await tester.enterText(find.byKey(Key('password_field')), '123456');
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pump();

    // Assert
    expect(find.text('Username required'), findsNothing);
    expect(find.text('Password too short'), findsNothing);
  });
}
```

### 5.3 Test với ListView và Scroll

```dart
// File: test/widget/list_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Should display list of items and scroll', 
    (WidgetTester tester) async {
    // Arrange
    final items = List.generate(50, (i) => 'Item $i');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(items[index]),
            ),
          ),
        ),
      ),
    );

    // Assert - Item 0 visible
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 49'), findsNothing);

    // Act - Scroll to bottom
    await tester.drag(find.byType(ListView), Offset(0, -10000));
    await tester.pumpAndSettle();

    // Assert - Item 49 visible
    expect(find.text('Item 49'), findsOneWidget);
  });
}
```

---

## 6. BLOC TEST

### 6.1 Test Cubit đơn giản

```dart
// File: test/bloc/counter_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Counter Cubit
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}

void main() {
  group('CounterCubit', () {
    late CounterCubit counterCubit;

    setUp(() {
      counterCubit = CounterCubit();
    });

    tearDown(() {
      counterCubit.close();
    });

    test('initial state should be 0', () {
      expect(counterCubit.state, 0);
    });

    blocTest<CounterCubit, int>(
      'increment should emit 1',
      build: () => CounterCubit(),
      act: (cubit) => cubit.increment(),
      expect: () => [1],
    );

    blocTest<CounterCubit, int>(
      'increment twice should emit 1, 2',
      build: () => CounterCubit(),
      act: (cubit) {
        cubit.increment();
        cubit.increment();
      },
      expect: () => [1, 2],
    );

    blocTest<CounterCubit, int>(
      'decrement should emit -1',
      build: () => CounterCubit(),
      act: (cubit) => cubit.decrement(),
      expect: () => [-1],
    );

    blocTest<CounterCubit, int>(
      'reset should emit 0',
      build: () => CounterCubit(),
      seed: () => 5,
      act: (cubit) => cubit.reset(),
      expect: () => [0],
    );
  });
}
```

### 6.2 Test Cubit với State phức tạp

```dart
// File: test/bloc/login_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Login State
abstract class LoginState {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final String username;
  LoginSuccess(this.username);
}
class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

// Login Cubit
class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login(String username, String password) async {
    emit(LoginLoading());
    
    await Future.delayed(Duration(seconds: 1));
    
    if (username == 'admin' && password == 'password') {
      emit(LoginSuccess(username));
    } else {
      emit(LoginError('Invalid credentials'));
    }
  }
}

void main() {
  group('LoginCubit', () {
    late LoginCubit loginCubit;

    setUp(() {
      loginCubit = LoginCubit();
    });

    tearDown(() {
      loginCubit.close();
    });

    test('initial state should be LoginInitial', () {
      expect(loginCubit.state, isA<LoginInitial>());
    });

    blocTest<LoginCubit, LoginState>(
      'should emit [LoginLoading, LoginSuccess] when login successful',
      build: () => LoginCubit(),
      act: (cubit) => cubit.login('admin', 'password'),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginSuccess>()
          .having((s) => s.username, 'username', 'admin'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [LoginLoading, LoginError] when login fails',
      build: () => LoginCubit(),
      act: (cubit) => cubit.login('wrong', 'wrong'),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginError>()
          .having((s) => s.message, 'message', 'Invalid credentials'),
      ],
    );
  });
}
```

### 6.3 Test Widget với Bloc

```dart
// File: test/widget/counter_with_bloc_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock Cubit
class MockCounterCubit extends MockCubit<int> implements CounterCubit {}

// Counter Screen
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CounterCubit, int>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Count: $state', key: Key('counter_text')),
                ElevatedButton(
                  key: Key('increment_button'),
                  onPressed: () => context.read<CounterCubit>().increment(),
                  child: Text('Increment'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  late CounterCubit counterCubit;

  setUp(() {
    counterCubit = MockCounterCubit();
  });

  testWidgets('Should display counter value from cubit', 
    (WidgetTester tester) async {
    // Arrange
    when(() => counterCubit.state).thenReturn(5);
    when(() => counterCubit.stream).thenAnswer((_) => Stream.value(5));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CounterCubit>.value(
          value: counterCubit,
          child: CounterScreen(),
        ),
      ),
    );

    // Assert
    expect(find.text('Count: 5'), findsOneWidget);
  });

  testWidgets('Should call increment when button pressed', 
    (WidgetTester tester) async {
    // Arrange
    when(() => counterCubit.state).thenReturn(0);
    when(() => counterCubit.stream).thenAnswer((_) => Stream.value(0));
    when(() => counterCubit.increment()).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CounterCubit>.value(
          value: counterCubit,
          child: CounterScreen(),
        ),
      ),
    );

    // Act
    await tester.tap(find.byKey(Key('increment_button')));
    await tester.pump();

    // Assert
    verify(() => counterCubit.increment()).called(1);
  });
}
```

---

## 7. INTEGRATION TEST

### 7.1 Setup Integration Test

```dart
// File: integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:testflutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Complete login flow', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Find login fields
      final usernameField = find.byKey(Key('username_field'));
      final passwordField = find.byKey(Key('password_field'));
      final loginButton = find.byKey(Key('login_button'));

      // Enter credentials
      await tester.enterText(usernameField, 'testuser');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tap login
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify navigation to home
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

---

## 8. MOCKING VỚI MOCKTAIL

### 8.1 Mock HTTP Client

```dart
// File: test/unit/api_client_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

// Mock HTTP Client
class MockHttpClient extends Mock implements http.Client {}

// API Service
class ApiService {
  final http.Client client;
  ApiService(this.client);

  Future<String> fetchData() async {
    final response = await client.get(
      Uri.parse('https://api.example.com/data'),
    );
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception('Failed to load data');
  }
}

void main() {
  late MockHttpClient mockClient;
  late ApiService apiService;

  setUp(() {
    mockClient = MockHttpClient();
    apiService = ApiService(mockClient);
  });

  test('should return data when API call is successful', () async {
    // Arrange
    when(() => mockClient.get(any())).thenAnswer(
      (_) async => http.Response('{"data": "success"}', 200),
    );

    // Act
    final result = await apiService.fetchData();

    // Assert
    expect(result, '{"data": "success"}');
    verify(() => mockClient.get(any())).called(1);
  });

  test('should throw exception when API call fails', () async {
    // Arrange
    when(() => mockClient.get(any())).thenAnswer(
      (_) async => http.Response('Not Found', 404),
    );

    // Act & Assert
    expect(
      () => apiService.fetchData(),
      throwsA(isA<Exception>()),
    );
  });
}
```

### 8.2 Mock Repository

```dart
// File: test/unit/repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Repository Interface
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<void> saveUser(User user);
}

// Mock Repository
class MockUserRepository extends Mock implements UserRepository {}

// User Model
class User {
  final String id;
  final String name;
  User({required this.id, required this.name});
}

// Use Case
class GetUserUseCase {
  final UserRepository repository;
  GetUserUseCase(this.repository);

  Future<User> execute(String id) async {
    return await repository.getUser(id);
  }
}

void main() {
  late MockUserRepository mockRepository;
  late GetUserUseCase useCase;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetUserUseCase(mockRepository);
  });

  test('should get user from repository', () async {
    // Arrange
    final user = User(id: '1', name: 'Test User');
    when(() => mockRepository.getUser('1'))
        .thenAnswer((_) async => user);

    // Act
    final result = await useCase.execute('1');

    // Assert
    expect(result.id, '1');
    expect(result.name, 'Test User');
    verify(() => mockRepository.getUser('1')).called(1);
  });

  test('should handle repository errors', () async {
    // Arrange
    when(() => mockRepository.getUser('1'))
        .thenThrow(Exception('User not found'));

    // Act & Assert
    expect(
      () => useCase.execute('1'),
      throwsA(isA<Exception>()),
    );
  });
}
```

---

## 9. BEST PRACTICES

### 9.1 Cấu trúc Test
```dart
void main() {
  // Group tests theo chức năng
  group('Feature Name', () {
    // Khai báo biến chung
    late MyClass myClass;
    
    // Setup trước mỗi test
    setUp(() {
      myClass = MyClass();
    });
    
    // Cleanup sau mỗi test
    tearDown(() {
      // Clean up resources
    });
    
    // Viết test cases
    test('should do something', () {
      // Arrange - Chuẩn bị dữ liệu
      final input = 'test';
      
      // Act - Thực hiện hành động
      final result = myClass.doSomething(input);
      
      // Assert - Kiểm tra kết quả
      expect(result, 'expected');
    });
  });
}
```

### 9.2 Naming Conventions
```dart
// ✅ GOOD - Mô tả rõ ràng
test('should return user when ID is valid', () {});
test('should throw exception when user not found', () {});
testWidgets('should display error message when login fails', () {});

// ❌ BAD - Không rõ ràng
test('test 1', () {});
test('user test', () {});
```

### 9.3 Test Coverage
- Aim for 80%+ code coverage
- Prioritize critical business logic
- Test edge cases and error handling

### 9.4 Test Independence
```dart
// ✅ GOOD - Mỗi test độc lập
test('test A', () {
  final data = createTestData();
  expect(data.value, 1);
});

test('test B', () {
  final data = createTestData();
  expect(data.value, 1);
});

// ❌ BAD - Tests phụ thuộc nhau
int sharedValue = 0;

test('test A', () {
  sharedValue = 1;
});

test('test B', () {
  expect(sharedValue, 1); // Phụ thuộc vào test A
});
```

---

## 10. CHẠY TESTS

### 10.1 Commands cơ bản

```bash
# Chạy tất cả tests
flutter test

# Chạy một test file cụ thể
flutter test test/unit/user_model_test.dart

# Chạy tests với coverage
flutter test --coverage

# Chạy integration tests
flutter test integration_test/app_test.dart

# Watch mode - tự động chạy khi file thay đổi
flutter test --watch

# Chạy tests với verbose output
flutter test --verbose
```

### 10.2 Xem Test Coverage

```bash
# Generate coverage report
flutter test --coverage

# View HTML report (cần cài lcov)
# Windows: choco install lcov
# Mac: brew install lcov

genhtml coverage/lcov.info -o coverage/html
# Mở coverage/html/index.html trong browser
```

### 10.3 Chạy tests trong CI/CD

```yaml
# .github/workflows/test.yml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter test integration_test/
```

---

## 📖 TÀI LIỆU THAM KHẢO

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Bloc Test Package](https://pub.dev/packages/bloc_test)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Integration Test Package](https://pub.dev/packages/integration_test)

---

## 💡 TIPS & TRICKS

1. **Sử dụng Keys** cho widgets để dễ tìm trong tests
2. **Mock dependencies** thay vì gọi API thật
3. **Test edge cases** như null, empty, errors
4. **Keep tests fast** - Unit tests < 100ms
5. **Write descriptive test names** - Ai cũng hiểu test làm gì
6. **Test behavior, not implementation** - Test cái gì xảy ra, không test làm thế nào
7. **Use setUp/tearDown** để tránh code trùng lặp
8. **Group related tests** để dễ quản lý

---

## 🎯 CHECKLIST ĐỂ BẮT ĐẦU TEST

- [ ] Hiểu các loại test: Unit, Widget, Integration
- [ ] Setup dependencies: flutter_test, bloc_test, mocktail
- [ ] Tạo cấu trúc thư mục test/
- [ ] Viết unit test đầu tiên
- [ ] Viết widget test đầu tiên
- [ ] Học cách mock dependencies
- [ ] Test Bloc/Cubit
- [ ] Chạy tests và xem coverage
- [ ] Tích hợp tests vào CI/CD

**Chúc bạn test hiệu quả! 🚀**