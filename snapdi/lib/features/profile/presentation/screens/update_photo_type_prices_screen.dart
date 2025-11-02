import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/services/photo_type_pricing_service.dart';
import '../../data/models/photo_type_with_pricing.dart';
import '../../../auth/data/models/photographer_photo_type.dart';

class UpdatePhotoTypePricesScreen extends StatefulWidget {
  const UpdatePhotoTypePricesScreen({super.key});

  @override
  State<UpdatePhotoTypePricesScreen> createState() =>
      _UpdatePhotoTypePricesScreenState();
}

class _UpdatePhotoTypePricesScreenState
    extends State<UpdatePhotoTypePricesScreen> {
  final _pricingService = PhotoTypePricingServiceImpl();
  final _currencyFormatter = NumberFormat('#,###', 'en_US');

  List<PhotoTypeWithPricing> _photoTypes = [];
  Map<int, TextEditingController> _priceControllers = {};
  Map<int, TextEditingController> _timeControllers = {};
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadPhotoTypes();
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    for (var controller in _timeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPhotoTypes() async {
    setState(() => _isLoading = true);
    final result = await _pricingService.getMyPhotoTypes();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể tải loại hình chụp ảnh: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
      (photoTypes) {
        if (mounted) {
          setState(() {
            _photoTypes = photoTypes;
            // Initialize controllers for photo types with existing prices
            for (var photoType in photoTypes) {
              if (photoType.photoPrice != null) {
                _priceControllers[photoType.photoTypeId] =
                    TextEditingController(
                  text: _formatCurrency(photoType.photoPrice!),
                );
                _timeControllers[photoType.photoTypeId] =
                    TextEditingController(
                  text: photoType.time?.toString() ?? '',
                );
              }
            }
            _isLoading = false;
          });
        }
      },
    );
  }

  String _formatCurrency(double value) {
    return _currencyFormatter.format(value.toInt());
  }

  double _parseCurrency(String value) {
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  void _showPhotoTypePriceDialog(PhotoTypeWithPricing photoType) {
    final priceController = TextEditingController();
    final timeController = TextEditingController();

    // Pre-fill with existing values if available
    if (_priceControllers.containsKey(photoType.photoTypeId)) {
      priceController.text = _priceControllers[photoType.photoTypeId]!.text;
      timeController.text = _timeControllers[photoType.photoTypeId]!.text;
    } else if (photoType.photoPrice != null) {
      priceController.text = _formatCurrency(photoType.photoPrice!);
      timeController.text = photoType.time?.toString() ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đặt giá & thời gian cho ${photoType.photoTypeName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Giá (VNĐ)',
                hintText: 'Ví dụ: 500,000',
                suffixText: 'VNĐ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Thời gian (giờ)',
                hintText: 'Nhập thời gian ước tính',
                suffixText: 'giờ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final priceValue = _parseCurrency(priceController.text);
              final time = int.tryParse(timeController.text);

              if (priceValue <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Giá phải lớn hơn 0'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (time == null || time <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thời gian phải lớn hơn 0'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              // Save to controllers
              setState(() {
                _priceControllers[photoType.photoTypeId] = priceController;
                _timeControllers[photoType.photoTypeId] = timeController;
              });

              Navigator.pop(context);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdatePrices() async {
    // Collect all photo types with prices
    final List<PhotographerPhotoType> pricesToUpdate = [];

    for (var photoType in _photoTypes) {
      if (_priceControllers.containsKey(photoType.photoTypeId) &&
          _timeControllers.containsKey(photoType.photoTypeId)) {
        final priceValue =
            _parseCurrency(_priceControllers[photoType.photoTypeId]!.text);
        final timeValue =
            int.tryParse(_timeControllers[photoType.photoTypeId]!.text);

        if (priceValue <= 0 || timeValue == null || timeValue <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Vui lòng đặt giá và thời gian hợp lệ cho ${photoType.photoTypeName}'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        pricesToUpdate.add(
          PhotographerPhotoType(
            photoTypeId: photoType.photoTypeId,
            photoPrice: priceValue,
            time: timeValue,
          ),
        );
      }
    }

    if (pricesToUpdate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một loại hình chụp ảnh'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận cập nhật giá'),
        content: const Text(
            'Bạn có chắc chắn muốn cập nhật giá? Sau khi xác nhận, level của bạn sẽ được reset để admin xem xét lại.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUpdating = true);

    final result = await _pricingService.updatePhotoTypePrices(pricesToUpdate);
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể cập nhật giá: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      },
      (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Cập nhật giá thành công! Level của bạn đã được reset để admin xem xét.'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate update
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật giá chụp ảnh'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bảng giá chụp',
                    style: AppTextStyles.headline4,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm hoặc cập nhật giá chụp theo từng thể loại chụp ảnh',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginLarge),
                  if (_photoTypes.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Không có loại hình chụp ảnh nào'),
                      ),
                    )
                  else
                    ..._photoTypes.map((photoType) {
                      final hasPrice = _priceControllers
                          .containsKey(photoType.photoTypeId);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(photoType.photoTypeName),
                          subtitle: hasPrice
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Giá: ${_priceControllers[photoType.photoTypeId]!.text} VNĐ',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    Text(
                                      'Thời gian: ${_timeControllers[photoType.photoTypeId]!.text} giờ',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Chưa đặt giá',
                                  style: TextStyle(color: Colors.grey),
                                ),
                          trailing: IconButton(
                            icon: Icon(
                              hasPrice ? Icons.edit : Icons.add,
                              color: AppColors.primary,
                            ),
                            onPressed: () =>
                                _showPhotoTypePriceDialog(photoType),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: AppDimensions.marginXLarge),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _handleUpdatePrices,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white),
                              ),
                            )
                          : const Text(
                              'Xác nhận cập nhật giá',
                              style: AppTextStyles.buttonLarge,
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Currency Input Formatter
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse and format
    int value = int.parse(digitsOnly);
    String formatted = _formatter.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


