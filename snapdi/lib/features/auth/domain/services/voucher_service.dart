// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import '../../../../core/error/failures.dart';
// import '../../../../core/network/api_service.dart';
// import '../../data/models/voucher_model.dart';

// abstract class VoucherService {
//   Future<Either<Failure, List<VoucherModel>>> getVouchers();
//   Future<Either<Failure, VoucherModel>> getVoucherById(int id);
//   Future<Either<Failure, Unit>> createVoucher(VoucherModel model);
//   Future<Either<Failure, Unit>> updateVoucher(VoucherModel model);
//   Future<Either<Failure, Unit>> deleteVoucher(int id);
// }

// class VoucherServiceImpl implements VoucherService {
//   final ApiService _apiService;

//   VoucherServiceImpl({ApiService? apiService})
//       : _apiService = apiService ?? ApiService();

//   @override
//   Future<Either<Failure, List<VoucherModel>>> getVouchers() async {
//     try {
//       final response = await _apiService.get('/api/Vouchers');
//       if (response.statusCode == 200) {
//         final vouchers = (response.data as List)
//             .map((json) => VoucherModel.fromJson(json))
//             .toList();
//         return Right(vouchers);
//       } else {
//         return Left(ServerFailure('Error: ${response.statusCode}'));
//       }
//     } on DioException catch (e) {
//       return Left(_handleError(e));
//     }
//   }

//   @override
//   Future<Either<Failure, VoucherModel>> getVoucherById(int id) async {
//     try {
//       final response = await _apiService.get('/api/Vouchers/$id');
//       if (response.statusCode == 200) {
//         return Right(VoucherModel.fromJson(response.data));
//       }
//       return Left(ServerFailure('Not found: ${response.statusCode}'));
//     } on DioException catch (e) {
//       return Left(_handleError(e));
//     }
//   }

//   @override
//   Future<Either<Failure, Unit>> createVoucher(VoucherModel model) async {
//     try {
//       final response = await _apiService.post('/api/Vouchers', data: model.toJson());
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return const Right(unit);
//       }
//       return Left(ServerFailure('Create failed'));
//     } on DioException catch (e) {
//       return Left(_handleError(e));
//     }
//   }

//   @override
//   Future<Either<Failure, Unit>> updateVoucher(VoucherModel model) async {
//     try {
//       final response = await _apiService.put(
//         '/api/Vouchers/${model.voucherId}',
//         data: model.toJson(),
//       );
//       if (response.statusCode == 204) return const Right(unit);
//       return Left(ServerFailure('Update failed'));
//     } on DioException catch (e) {
//       return Left(_handleError(e));
//     }
//   }

//   @override
//   Future<Either<Failure, Unit>> deleteVoucher(int id) async {
//     try {
//       final response = await _apiService.delete('/api/Vouchers/$id');
//       if (response.statusCode == 204) return const Right(unit);
//       return Left(ServerFailure('Delete failed'));
//     } on DioException catch (e) {
//       return Left(_handleError(e));
//     }
//   }

//   Failure _handleError(DioException e) =>
//       ServerFailure(e.message ?? 'Network error');
// }
