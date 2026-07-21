import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Simple Counter Cubit for testing
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
  void setValue(int value) => emit(value);
}

void main() {
  group('CounterCubit Tests', () {
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
      'decrement from 5 should emit 4',
      build: () => CounterCubit(),
      seed: () => 5,
      act: (cubit) => cubit.decrement(),
      expect: () => [4],
    );

    blocTest<CounterCubit, int>(
      'reset should emit 0',
      build: () => CounterCubit(),
      seed: () => 10,
      act: (cubit) => cubit.reset(),
      expect: () => [0],
    );

    blocTest<CounterCubit, int>(
      'setValue should emit the provided value',
      build: () => CounterCubit(),
      act: (cubit) => cubit.setValue(42),
      expect: () => [42],
    );

    blocTest<CounterCubit, int>(
      'multiple operations should emit correct sequence',
      build: () => CounterCubit(),
      act: (cubit) {
        cubit.increment(); // 0 -> 1
        cubit.increment(); // 1 -> 2
        cubit.decrement(); // 2 -> 1
        cubit.setValue(10); // 1 -> 10
        cubit.reset(); // 10 -> 0
      },
      expect: () => [1, 2, 1, 10, 0],
    );
  });
}import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Simple Counter Cubit for testing
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
  void setValue(int value) => emit(value);
}

void main() {
  group('CounterCubit Tests', () {
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
      'decrement from 5 should emit 4',
      build: () => CounterCubit(),
      seed: () => 5,
      act: (cubit) => cubit.decrement(),
      expect: () => [4],
    );

    blocTest<CounterCubit, int>(
      'reset should emit 0',
      build: () => CounterCubit(),
      seed: () => 10,
      act: (cubit) => cubit.reset(),
      expect: () => [0],
    );

    blocTest<CounterCubit, int>(
      'setValue should emit the provided value',
      build: () => CounterCubit(),
      act: (cubit) => cubit.setValue(42),
      expect: () => [42],
    );

    blocTest<CounterCubit, int>(
      'multiple operations should emit correct sequence',
      build: () => CounterCubit(),
      act: (cubit) {
        cubit.increment(); // 0 -> 1
        cubit.increment(); // 1 -> 2
        cubit.decrement(); // 2 -> 1
        cubit.setValue(10); // 1 -> 10
        cubit.reset(); // 10 -> 0
      },
      expect: () => [1, 2, 1, 10, 0],
    );
  });
