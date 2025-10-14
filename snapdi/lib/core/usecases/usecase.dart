import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoParams;
  }

  @override
  int get hashCode => 0;
}
