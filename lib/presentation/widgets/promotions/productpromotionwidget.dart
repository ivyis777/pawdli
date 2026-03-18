import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pawlli/data/controller/productpromotioncontroller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pawlli/core/storage_manager/colors.dart';

class Productpromotion extends StatelessWidget {
  Productpromotion({super.key});

  final Productpromotioncontroller controller =
      Get.put(Productpromotioncontroller());

  Future<void> _launchURL(String url) async {
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

  bool _isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _isFullUrl(String url) {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  Widget _imageLoader(String image) {
    // debugPrint("🟦 PRODUCT IMAGE → $image");

    if (image.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    }

    if (_isFullUrl(image)) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 50, color: Colors.red),
      );
    }

    if (_isBase64(image)) {
      try {
        return Image.memory(
          base64Decode(image),
          fit: BoxFit.cover,
          width: double.infinity,
        );
      } catch (_) {}
    }

    return const Icon(Icons.broken_image, size: 50, color: Colors.red);
  }

  Widget _placeholderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 224, 222, 222),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colours.primarycolour),
          const SizedBox(height: 10),
          Text(
            "Coming Soon",
            style: TextStyle(
              fontSize: 14,
              color: Colours.primarycolour,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.promotions.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              viewportFraction: 1,
            ),
            items: [
              _placeholderCard(),
              _placeholderCard(),
              _placeholderCard(),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            viewportFraction: 1.0,
            enlargeCenterPage: true,
          ),
          items: controller.promotions.map((promo) {
            /// FINAL FIX → Get image from BOTH fields
            final image = (promo.imageUrl != null &&
                    promo.imageUrl!.trim().isNotEmpty)
                ? promo.imageUrl!
                : (promo.image ?? "");

            // debugPrint("💛 FINAL PRODUCT IMAGE USED → $image");

            return GestureDetector(
              onTap: () => _launchURL(promo.url ?? ""),
              child: Card(
                color: Colours.secondarycolour,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _imageLoader(image),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
