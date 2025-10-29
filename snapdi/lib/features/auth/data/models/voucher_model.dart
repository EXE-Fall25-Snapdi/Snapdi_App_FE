// import 'package:json_annotation/json_annotation.dart';
// import '../../domain/entities/voucher.dart';

// part 'voucher_model.g.dart';

// @JsonSerializable()
// class VoucherModel extends Voucher {
//   const VoucherModel({
//     required super.voucherId,
//     required super.code,
//     super.description,
//     super.discountType,
//     required super.discountValue,
//     super.maxDiscount,
//     super.minSpend,
//     required super.startDate,
//     required super.endDate,
//     super.usageLimit,
//     required super.isActive,
//   });

//   factory VoucherModel.fromJson(Map<String, dynamic> json) =>
//       _$VoucherModelFromJson(json);

//   Map<String, dynamic> toJson() => _$VoucherModelToJson(this);

//   factory VoucherModel.fromEntity(Voucher entity) => VoucherModel(
//     voucherId: entity.voucherId,
//     code: entity.code,
//     description: entity.description,
//     discountType: entity.discountType,
//     discountValue: entity.discountValue,
//     maxDiscount: entity.maxDiscount,
//     minSpend: entity.minSpend,
//     startDate: entity.startDate,
//     endDate: entity.endDate,
//     usageLimit: entity.usageLimit,
//     isActive: entity.isActive,
//   );
// }
