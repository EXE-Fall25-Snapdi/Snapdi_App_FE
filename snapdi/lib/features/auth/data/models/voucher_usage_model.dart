import 'package:json_annotation/json_annotation.dart';
import 'package:snapdi/features/auth/domain/entities/voucher_usage.dart';

part 'voucher_usage_model.g.dart';

@JsonSerializable()
class VoucherUsageModel extends VoucherUsage {
  VoucherUsageModel({
    required super.voucherUsageId,
    required super.bookingId,
    required super.voucherId,
    required super.userId,
    required super.usedAt
  });

  factory VoucherUsageModel.fromJson(Map<String, dynamic> json) =>
      _$VoucherUsageModelFromJson(json);

  Map<String, dynamic> toJson() => _$VoucherUsageModelToJson(this);

  factory VoucherUsageModel.fromEntity(VoucherUsage entity) => VoucherUsageModel(
    voucherUsageId: entity.voucherUsageId,
    bookingId: entity.bookingId,
    voucherId: entity.voucherId,
    userId: entity.userId,
    usedAt: entity.usedAt
  );
}