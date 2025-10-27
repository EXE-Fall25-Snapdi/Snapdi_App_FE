import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/utils/utils.dart';
import '../../data/services/style_service.dart';
import '../../data/services/photo_type_service.dart';
import '../../data/services/nominatim_service.dart';
import '../../data/models/style.dart';
import '../../data/models/photo_type.dart';
import 'finding_snappers_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final String? selectedLocation;

  const BookingDetailScreen({super.key, this.selectedLocation});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedCategory;
  int? _selectedCategoryId;
  String? _selectedStyle;
  int? _selectedStyleId;
  final TextEditingController _userLocationController = TextEditingController();
  final TextEditingController _bookingLocationController =
      TextEditingController();
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TokenStorage _tokenStorage = TokenStorage.instance;
  final StyleService _styleService = StyleService();
  final PhotoTypeService _photoTypeService = PhotoTypeService();
  final NominatimService _nominatimService = NominatimService();
  bool _isSubmitting = false;
  bool _useUserLocation = true;
  String _chosenBookingLocation = '';
  bool _isLoadingData = true;
  bool _isLoadingUserLocation = false;

  List<PhotoType> _photoTypes = [];
  List<Style> _styles = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    if (widget.selectedLocation != null) {
      _bookingLocationController.text = widget.selectedLocation!;
      _chosenBookingLocation = widget.selectedLocation!;
      _useUserLocation = false;
    } else {
      _useUserLocation = true;
      _getUserCurrentLocation();
    }
    _bookingLocationController.addListener(() {
      if (!_useUserLocation) {
        _chosenBookingLocation = _bookingLocationController.text;
      }
    });
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final photoTypes = await _photoTypeService.getPhotoTypes();
      final styles = await _styleService.getStyles();

      if (mounted) {
        setState(() {
          _photoTypes = photoTypes;
          _styles = styles;
          _selectedCategory = 'Tất cả';
          _selectedCategoryId = null;
          _selectedStyle = 'Tất cả';
          _selectedStyleId = null;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _userLocationController.dispose();
    _bookingLocationController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getUserCurrentLocation() async {
    setState(() {
      _isLoadingUserLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingUserLocation = false;
          });
          if (mounted) {
            _showErrorDialog('Quyền truy cập vị trí bị từ chối');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingUserLocation = false;
        });
        if (mounted) {
          _showErrorDialog(
            'Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng bật trong cài đặt.',
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      try {
        final suggestion = await _nominatimService.reverseGeocode(
          position.latitude,
          position.longitude,
        );

        if (mounted && suggestion != null) {
          setState(() {
            _userLocationController.text = suggestion.displayName;
            _isLoadingUserLocation = false;
          });
        } else {
          setState(() {
            _userLocationController.text =
                'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
            _isLoadingUserLocation = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _userLocationController.text =
                'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
            _isLoadingUserLocation = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserLocation = false;
        });
        _showErrorDialog('Không thể lấy vị trí hiện tại: ${e.toString()}');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;

        final now = DateTime.now();
        if (picked.year == now.year &&
            picked.month == now.month &&
            picked.day == now.day) {
          final selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _selectedTime.hour,
            _selectedTime.minute,
          );

          if (selectedDateTime.isBefore(now)) {
            _selectedTime = TimeOfDay.now();
          }
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();

    TimeOfDay initialTime = _selectedTime;

    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      final selectedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (selectedDateTime.isBefore(now)) {
        initialTime = currentTime;
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.black,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              timePickerTheme: TimePickerThemeData(
                hourMinuteTextStyle: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                dayPeriodTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (picked != null) {
      final selectedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        picked.hour,
        picked.minute,
      );

      if (selectedDateTime.isBefore(DateTime.now())) {
        _showErrorDialog('Không thể chọn thời gian trong quá khứ');
        return;
      }

      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_bookingLocationController.text.isEmpty) {
      _showErrorDialog('Vui lòng chọn địa điểm chụp ảnh');
      return;
    }

    // Parse budget values - this extracts the numeric value from formatted string
    int? minBudget;
    int? maxBudget;

    if (_minBudgetController.text.isNotEmpty) {
      minBudget = StringUtils.parseVNDToInt(_minBudgetController.text);
      if (minBudget < 0) {
        _showErrorDialog('Ngân sách tối thiểu không hợp lệ');
        return;
      }
    }

    if (_maxBudgetController.text.isNotEmpty) {
      maxBudget = StringUtils.parseVNDToInt(_maxBudgetController.text);
      if (maxBudget < 0) {
        _showErrorDialog('Ngân sách tối đa không hợp lệ');
        return;
      }
    }

    if (minBudget != null && maxBudget != null && minBudget > maxBudget) {
      _showErrorDialog(
        'Ngân sách tối thiểu không thể lớn hơn ngân sách tối đa',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = await _tokenStorage.getUserId();
      if (userId == null) {
        _showErrorDialog('Không tìm thấy thông tin người dùng');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final activeLocation = _useUserLocation
          ? _userLocationController.text
          : _bookingLocationController.text;

      print('Navigating to FindingSnappersScreen with minBudget: $minBudget, maxBudget: $maxBudget');    

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FindingSnappersScreen(
            location: activeLocation,
            date: _selectedDate,
            time: _selectedTime,
            city: activeLocation.isEmpty ? '' : activeLocation,
            styleIds: _selectedStyleId != null ? [_selectedStyleId!] : [],
            photoTypeIds: _selectedCategoryId != null
                ? [_selectedCategoryId!]
                : [],
            minBudget: minBudget, // Numeric value: 500000
            maxBudget: maxBudget, // Numeric value: 1000000
            customerId: userId,
            locationAddress: activeLocation,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Lỗi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location section
                    _buildSectionCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    _buildLocationTextField(
                                      icon: AppAssets.locationIcon,
                                      controller: _userLocationController,
                                      hintText: _isLoadingUserLocation
                                          ? 'Đang lấy vị trí...'
                                          : 'Vị trí hiện tại',
                                      isActive: _useUserLocation,
                                      readOnly: _useUserLocation,
                                    ),
                                    if (_isLoadingUserLocation)
                                      Positioned(
                                        right: 12,
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary,
                                                ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5F2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  tooltip: _useUserLocation
                                      ? 'Sử dụng vị trí của bạn'
                                      : 'Sử dụng vị trí đã chọn',
                                  onPressed: () async {
                                    setState(() {
                                      _useUserLocation = !_useUserLocation;
                                    });

                                    if (_useUserLocation) {
                                      await _getUserCurrentLocation();
                                    } else {
                                      _bookingLocationController.text =
                                          _chosenBookingLocation;
                                    }
                                  },
                                  icon: Icon(
                                    _useUserLocation
                                        ? Icons.my_location
                                        : Icons.place,
                                    color: _useUserLocation
                                        ? AppColors.primary
                                        : Colors.grey[700],
                                    size: 20,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildLocationTextField(
                            icon: AppAssets.searchIcon,
                            controller: _bookingLocationController,
                            hintText: 'Khu vực tìm kiếm Snapper',
                            readOnly: _useUserLocation,
                            isActive: !_useUserLocation,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date and Time section
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Thời gian chụp',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB8D4CF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_month,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _selectTime(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB8D4CF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedTime.format(context),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Category and Style section
                    Row(
                      children: [
                        Expanded(
                          child: _buildSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.category,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Thể loại',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _isLoadingData
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : _photoTypes.isEmpty
                                    ? const Text('Không có dữ liệu')
                                    : _buildPhotoTypeDropdown(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Phong cách',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _isLoadingData
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : _styles.isEmpty
                                    ? const Text('Không có dữ liệu')
                                    : _buildStyleDropdown(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Budget section with VND formatting
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Ngân sách',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Min budget
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tối thiểu',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB8D4CF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'VNĐ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              controller: _minBudgetController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                CurrencyInputFormatter(),
                                              ],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Max budget
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tối đa',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB8D4CF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'VNĐ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              controller: _maxBudgetController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                CurrencyInputFormatter(),
                                              ],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notes section
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.note_alt_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Ghi chú',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 120,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB8D4CF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _notesController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Thêm ghi chú cho buổi chụp...',
                                hintStyle: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text(
                      'Tìm ngay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLocationTextField({
    required String icon,
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFFE8F5F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.primary : Colors.transparent,
          width: isActive ? 1.5 : 0,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(icon, width: 20, height: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFB8D4CF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(Icons.expand_more, color: AppColors.primary),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          items: [
            const DropdownMenuItem<String>(
              value: 'Tất cả',
              child: Text('Tất cả'),
            ),
            ..._photoTypes.map((PhotoType photoType) {
              return DropdownMenuItem<String>(
                value: photoType.photoTypeName,
                child: Text(photoType.photoTypeName),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
              if (value == 'Tất cả') {
                _selectedCategoryId = null;
              } else {
                _selectedCategoryId = _photoTypes
                    .firstWhere((pt) => pt.photoTypeName == value)
                    .photoTypeId;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildStyleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFB8D4CF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStyle,
          isExpanded: true,
          icon: Icon(Icons.expand_more, color: AppColors.primary),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          items: [
            const DropdownMenuItem<String>(
              value: 'Tất cả',
              child: Text('Tất cả'),
            ),
            ..._styles.map((Style style) {
              return DropdownMenuItem<String>(
                value: style.styleName,
                child: Text(style.styleName),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedStyle = value;
              if (value == 'Tất cả') {
                _selectedStyleId = null;
              } else {
                _selectedStyleId = _styles
                    .firstWhere((s) => s.styleName == value)
                    .styleId;
              }
            });
          },
        ),
      ),
    );
  }
}
