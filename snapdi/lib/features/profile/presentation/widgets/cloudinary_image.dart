import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/services/cloudinary_service.dart';

class CloudinaryImage extends StatefulWidget {
  final String? publicId;
  final int? width;
  final int? height;
  final String? crop;
  final String? gravity;
  final int? quality;
  final String? format;
  final bool autoOptimize;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxFit? fit;

  const CloudinaryImage({
    super.key,
    required this.publicId,
    this.width,
    this.height,
    this.crop,
    this.gravity,
    this.quality,
    this.format,
    this.autoOptimize = true,
    this.placeholder,
    this.errorWidget,
    this.fit,
  });

  @override
  State<CloudinaryImage> createState() => _CloudinaryImageState();
}

class _CloudinaryImageState extends State<CloudinaryImage> {
  final _cloudinaryService = CloudinaryServiceImpl();
  String? _imageUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
  }

  @override
  void didUpdateWidget(CloudinaryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.publicId != widget.publicId ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.crop != widget.crop ||
        oldWidget.gravity != widget.gravity ||
        oldWidget.quality != widget.quality ||
        oldWidget.format != widget.format ||
        oldWidget.autoOptimize != widget.autoOptimize) {
      _loadImageUrl();
    }
  }

  Future<void> _loadImageUrl() async {
    if (widget.publicId == null || widget.publicId!.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final result = await _cloudinaryService.getTransformedImageUrl(
      widget.publicId!,
      width: widget.width,
      height: widget.height,
      crop: widget.crop,
      gravity: widget.gravity,
      quality: widget.quality,
      format: widget.format,
      autoOptimize: widget.autoOptimize,
    );

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        },
        (url) {
          setState(() {
            _imageUrl = url;
            _isLoading = false;
            _hasError = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ??
          const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _imageUrl == null) {
      return widget.errorWidget ?? const Center(child: Icon(Icons.error));
    }

    return CachedNetworkImage(
      imageUrl: _imageUrl!,
      fit: widget.fit ?? BoxFit.cover,
      placeholder: (context, url) =>
          widget.placeholder ??
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          widget.errorWidget ?? const Center(child: Icon(Icons.error)),
      // Thêm caching options để cải thiện hiệu suất
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
    );
  }
}
