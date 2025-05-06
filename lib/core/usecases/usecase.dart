// Path: lib/core/usecases/usecase.dart
import 'package:equatable/equatable.dart';

// Lưu ý: 'package:dartz/dartz.dart' thường được dùng ở đây cho Either.
// Để giữ đơn giản, tạm thời chúng ta sẽ không dùng Either.
// Nếu bạn muốn xử lý lỗi mạnh mẽ hơn, hãy cân nhắc thêm package dartz.

// For UseCases that don't take parameters
abstract class UseCase<Type, NoParams> {
  Future<Type> call(
    NoParams params,
  ); // Hoặc Future<Either<Failure, Type>> call(NoParams params);
}

// For UseCases that take parameters
abstract class UseCaseWithParams<Type, Params> {
  Future<Type> call(
    Params params,
  ); // Hoặc Future<Either<Failure, Type>> call(Params params);
}

// A simple NoParams class, as we don't have dartz's Unit
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
