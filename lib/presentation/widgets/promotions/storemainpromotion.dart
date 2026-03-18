import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pawlli/data/controller/storepromotioncontroller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pawlli/core/storage_manager/colors.dart';

class Storemainpromotion extends StatelessWidget {
  Storemainpromotion({super.key});

  final Storepromotioncontroller controller =
      Get.find<Storepromotioncontroller>();

  /// ===============================
  /// URL LAUNCHER
  /// ===============================
  Future<void> _launchURL(String url) async {
    debugPrint("🔗 PROMO CLICK URL → $url");

    if (url.isEmpty) return;

    if (!url.startsWith("http")) {
      url = "https://$url";
    }

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("❌ Could not launch URL: $url");
    }
  }

  /// ===============================
  /// NORMALIZE IMAGE URL
  /// ===============================
  String _normalizeImage(String image) {
    if (image.isEmpty) return "";

    // Full URL
    if (image.startsWith("http://") || image.startsWith("https://")) {
      return image;
    }

    // Base64 image
    if (image.startsWith("data:image")) {
      return image;
    }

    // Relative path from backend
    final fullUrl = "https://app.pawdli.com/$image";
    debugPrint("🟢 NORMALIZED IMAGE URL → $fullUrl");
    return fullUrl;
  }

  /// ===============================
  /// IMAGE BUILDER
  /// ===============================
  Widget _getPromotionImage(String image) {
    debugPrint("🖼️ FINAL IMAGE USED → $image");

    if (image.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    }

    // Network image
    if (image.startsWith("http")) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) {
          debugPrint("❌ IMAGE LOAD FAILED → $image");
          return const Icon(Icons.broken_image, size: 50, color: Colors.red);
        },
      );
    }

    // Base64 image
    if (image.startsWith("data:image")) {
      try {
        return Image.memory(
          base64Decode(image.split(',').last),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (e) {
        debugPrint("❌ BASE64 IMAGE ERROR → $e");
      }
    }

    return const Icon(Icons.broken_image, size: 50, color: Colors.red);
  }

  /// ===============================
  /// UI
  /// ===============================
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // debugPrint("📦 PROMOTION COUNT → ${controller.promotion.length}");

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.promotion.isEmpty) {
        // debugPrint("⚠️ NO PROMOTIONS FOUND");
        return const SizedBox(); // keep UI clean
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
          ),
          items: controller.promotion.map((promo) {
            debugPrint("🟡 PROMO ITEM → ${promo.toJson()}");

            final rawImage =
                (promo.imageUrl != null && promo.imageUrl!.trim().isNotEmpty)
                    ? promo.imageUrl!.trim()
                    : (promo.image ?? "").trim();

            debugPrint("🟠 RAW IMAGE FROM API → $rawImage");

            final imageCandidate = _normalizeImage(rawImage);

            return GestureDetector(
              onTap: () => _launchURL(promo.url ?? ""),
              child: Card(
                color: Colours.secondarycolour,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _getPromotionImage(imageCandidate),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
