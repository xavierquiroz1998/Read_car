/// Minimal Either monad — avoids adding `dartz` as a dependency.
/// Right = success, Left = failure (conventional in FP).
sealed class Either<L, R> {
  const Either();

  bool get isRight => this is Right<L, R>;
  bool get isLeft => this is Left<L, R>;

  /// Execute [onLeft] or [onRight] depending on the result.
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return switch (this) {
      Left<L, R>(value: final v) => onLeft(v),
      Right<L, R>(value: final v) => onRight(v),
    };
  }

  /// Map over the right value, leaving left unchanged.
  Either<L, T> map<T>(T Function(R right) f) {
    return switch (this) {
      Left<L, R>(value: final v) => Left(v),
      Right<L, R>(value: final v) => Right(f(v)),
    };
  }
}

/// Represents a failure / error path.
final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

/// Represents a success path.
final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
