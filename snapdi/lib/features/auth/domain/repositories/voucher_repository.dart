import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/voucher.dart';

abstract class VoucherRepository {
  Future<Either<Failure, List<Voucher>>> getAllVouchers();
  Future<Either<Failure, Voucher>> getVoucherById({required int id});
  Future<Either<Failure, Unit>> createVoucher({required Voucher voucher});
  Future<Either<Failure, Unit>> updateVoucher({required Voucher voucher});
  Future<Either<Failure, Unit>> deleteVoucher({required int id});
}
