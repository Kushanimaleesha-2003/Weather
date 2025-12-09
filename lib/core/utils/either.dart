// Either type for functional error handling
sealed class Either<L, R> {
  const Either();
  
  /// Applies a function to transform the value inside Either
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return switch (this) {
      Left(value: final left) => onLeft(left),
      Right(value: final right) => onRight(right),
    };
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}

