import 'package:flutter_test/flutter_test.dart';
import 'package:read_car/core/errors/either.dart';

void main() {
  group('Either', () {
    // ── isRight / isLeft ───────────────────────────────────────────────────

    test('Right.isRight returns true', () {
      const either = Right<String, int>(42);
      expect(either.isRight, isTrue);
      expect(either.isLeft, isFalse);
    });

    test('Left.isLeft returns true', () {
      const either = Left<String, int>('error');
      expect(either.isLeft, isTrue);
      expect(either.isRight, isFalse);
    });

    // ── fold ──────────────────────────────────────────────────────────────

    test('fold calls onRight when Right', () {
      const either = Right<String, int>(10);
      final result = either.fold(
        (l) => 'left:$l',
        (r) => 'right:$r',
      );
      expect(result, 'right:10');
    });

    test('fold calls onLeft when Left', () {
      const either = Left<String, int>('failure');
      final result = either.fold(
        (l) => 'left:$l',
        (r) => 'right:$r',
      );
      expect(result, 'left:failure');
    });

    // ── map ───────────────────────────────────────────────────────────────

    test('map transforms Right value', () {
      const either = Right<String, int>(5);
      final mapped = either.map((v) => v * 2);
      expect(mapped.isRight, isTrue);
      expect(mapped.fold((_) => 0, (v) => v), 10);
    });

    test('map leaves Left unchanged', () {
      const either = Left<String, int>('err');
      final mapped = either.map((v) => v * 2);
      expect(mapped.isLeft, isTrue);
      expect(mapped.fold((l) => l, (_) => ''), 'err');
    });

    // ── value access ──────────────────────────────────────────────────────

    test('Right holds its value', () {
      const right = Right<String, int>(99);
      expect(right.value, 99);
    });

    test('Left holds its value', () {
      const left = Left<String, int>('oops');
      expect(left.value, 'oops');
    });

    // ── chaining / composition ────────────────────────────────────────────

    test('chained maps on Right accumulate correctly', () {
      const either = Right<String, int>(2);
      final result = either
          .map((v) => v + 3)    // 5
          .map((v) => v * 4);   // 20
      expect(result.fold((_) => -1, (v) => v), 20);
    });

    test('chained maps on Left short-circuit', () {
      const either = Left<String, int>('broken');
      final result = either
          .map((v) => v + 3)
          .map((v) => v * 4);
      expect(result.isLeft, isTrue);
    });

    // ── void Right (null payload) ─────────────────────────────────────────

    test('Right with null payload is valid', () {
      const either = Right<String, void>(null);
      expect(either.isRight, isTrue);
    });
  });
}
