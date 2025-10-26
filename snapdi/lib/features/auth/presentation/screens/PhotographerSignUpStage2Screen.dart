import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/custom_input_field.dart';
import '../../domain/services/auth_service.dart';
import 'PhotographerSignUpStage3Screen.dart';
import '../../data/models/photographer_stage1_data.dart';
import '../../data/models/photographer_stage2_data.dart';
import '../../data/models/photo_type.dart';
import '../../data/models/selected_photo_type.dart';
import '../../data/models/style.dart';

class PhotographerSignUpStage2Screen extends StatefulWidget {
  final PhotographerStage1Data stage1Data;

  const PhotographerSignUpStage2Screen({super.key, required this.stage1Data});

  @override
  State<PhotographerSignUpStage2Screen> createState() =>
      _PhotographerSignUpStage2ScreenState();
}

class _PhotographerSignUpStage2ScreenState
    extends State<PhotographerSignUpStage2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthServiceImpl();
  final _workLocationController = TextEditingController();
  final _currencyFormatter = NumberFormat(
    '#,###',
    'en_US',
  ); // Use comma separator

  List<PhotoType> _photoTypes = [];
  List<Style> _styles = [];
  bool _isLoadingPhotoTypes = true;
  bool _isLoadingStyles = true;

  List<SelectedPhotoType> _selectedPhotoTypes = [];
  Set<int> _selectedStyleIds = {};

  @override
  void initState() {
    super.initState();
    _loadPhotoTypes();
    _loadStyles();
  }

  @override
  void dispose() {
    _workLocationController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotoTypes() async {
    setState(() => _isLoadingPhotoTypes = true);
    try {
      final result = await _authService.getPhotoTypes();
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể tải loại hình chụp ảnh'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (photoTypes) {
          setState(() {
            _photoTypes = photoTypes;
            _isLoadingPhotoTypes = false;
          });
        },
      );
    } catch (e) {
      setState(() => _isLoadingPhotoTypes = false);
    }
  }

  Future<void> _loadStyles() async {
    setState(() => _isLoadingStyles = true);
    try {
      final result = await _authService.getStyles();
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể tải phong cách chụp ảnh'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (styles) {
          setState(() {
            _styles = styles;
            _isLoadingStyles = false;
          });
        },
      );
    } catch (e) {
      setState(() => _isLoadingStyles = false);
    }
  }

  String? _validateWorkLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập địa điểm làm việc';
    }
    if (value.length < 3) {
      return 'Địa điểm làm việc phải có ít nhất 3 ký tự';
    }
    return null;
  }

  String _formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }

  double _parseCurrency(String value) {
    // Remove all non-digit characters (commas, spaces, periods)
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPhotoTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng chọn ít nhất một loại hình chụp ảnh'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedStyleIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng chọn ít nhất một phong cách'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotographerSignUpStage3Screen(
            stage1Data: widget.stage1Data,
            stage2Data: PhotographerStage2Data(
              photoTypes: _selectedPhotoTypes,
              styleIds: _selectedStyleIds.toList(),
              workLocation: _workLocationController.text.trim(),
            ),
          ),
        ),
      );
    }
  }

  void _showPhotoTypePriceDialog(PhotoType photoType) {
    final priceController = TextEditingController();
    final timeController = TextEditingController();

    final existingIndex = _selectedPhotoTypes.indexWhere(
      (pt) => pt.photoTypeId == photoType.photoTypeId,
    );
    if (existingIndex != -1) {
      priceController.text = _formatCurrency(
        _selectedPhotoTypes[existingIndex].photoPrice,
      );
      timeController.text = _selectedPhotoTypes[existingIndex].time.toString();
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
              decoration: InputDecoration(
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
              decoration: InputDecoration(
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
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final priceValue = _parseCurrency(priceController.text);
              final time = int.tryParse(timeController.text);

              print('Parsed price: $priceValue'); // Debug log
              print('Original text: ${priceController.text}'); // Debug log

              if (priceValue == 0 || time == null || time == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vui lòng nhập giá và thời gian hợp lệ'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              setState(() {
                if (existingIndex != -1) {
                  _selectedPhotoTypes[existingIndex] = SelectedPhotoType(
                    photoTypeId: photoType.photoTypeId,
                    photoPrice: priceValue,
                    time: time,
                  );
                } else {
                  _selectedPhotoTypes.add(
                    SelectedPhotoType(
                      photoTypeId: photoType.photoTypeId,
                      photoPrice: priceValue,
                      time: time,
                    ),
                  );
                }
              });

              Navigator.pop(context);
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5F3), Color(0xFFF0F9F7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Loại hình & Phong cách',
                            style: AppTextStyles.headline3.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bước 2 / 3',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.marginXLarge),

                          Text(
                            'Loại hình chụp ảnh',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chọn loại hình và đặt giá & thời gian của bạn',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginMedium),

                          if (_isLoadingPhotoTypes)
                            Center(child: CircularProgressIndicator())
                          else
                            ..._photoTypes.map((photoType) {
                              final isSelected = _selectedPhotoTypes.any(
                                (pt) => pt.photoTypeId == photoType.photoTypeId,
                              );

                              String? priceTimeText;
                              if (isSelected) {
                                final selected = _selectedPhotoTypes.firstWhere(
                                  (pt) =>
                                      pt.photoTypeId == photoType.photoTypeId,
                                );
                                priceTimeText =
                                    '${_formatCurrency(selected.photoPrice)} VNĐ • ${selected.time} giờ';
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : const Color(0xFFB8D4D1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(photoType.photoTypeName),
                                  subtitle: priceTimeText != null
                                      ? Text(
                                          priceTimeText,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        )
                                      : null,
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                        )
                                      : Icon(
                                          Icons.circle_outlined,
                                          color: AppColors.textSecondary,
                                        ),
                                  onTap: () =>
                                      _showPhotoTypePriceDialog(photoType),
                                ),
                              );
                            }).toList(),

                          const SizedBox(height: AppDimensions.marginLarge),

                          Text(
                            'Phong cách nhiếp ảnh',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chọn tất cả các phong cách phù hợp',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginMedium),

                          if (_isLoadingStyles)
                            Center(child: CircularProgressIndicator())
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _styles.map((style) {
                                final isSelected = _selectedStyleIds.contains(
                                  style.styleId,
                                );
                                return FilterChip(
                                  label: Text(style.styleName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedStyleIds.add(style.styleId);
                                      } else {
                                        _selectedStyleIds.remove(style.styleId);
                                      }
                                    });
                                  },
                                  backgroundColor: const Color(0xFFB8D4D1),
                                  selectedColor: AppColors.primary.withOpacity(
                                    0.3,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                );
                              }).toList(),
                            ),

                          const SizedBox(height: AppDimensions.marginLarge),

                          Text(
                            'Địa điểm làm việc',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginMedium),

                          CustomInputField(
                            hintText: 'Ví dụ: TP. Hồ Chí Minh, Hà Nội, Đà Nẵng',
                            prefixIcon: Icons.location_on_outlined,
                            controller: _workLocationController,
                            validator: _validateWorkLocation,
                            keyboardType: TextInputType.text,
                          ),

                          const SizedBox(height: AppDimensions.marginXLarge),

                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Tiếp theo',
                                style: AppTextStyles.buttonLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
