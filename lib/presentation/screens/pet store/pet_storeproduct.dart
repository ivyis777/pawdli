import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/cartviewcontroller.dart';
import 'package:pawlli/data/model/productVariantmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/pet%20store/pet_cart.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/model/storeprocductmodel.dart' show Data, SelectedVariant;

class ProductDetailsScreen extends StatefulWidget {
  final Data product;
  // final productId = productId;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;
  int _currentImageIndex = 0;

  bool isOutOfStock = false;

  // Variant list
  List<StoreProductVariant> variants = [];
  StoreProductVariant? selectedVariant;

  bool isLoadingVariants = true;
  bool isAddingToCart = false;
  

  @override
  void initState() {
    super.initState();
    fetchProductVariants();
  }

void showTopSingleLinePopup({
  required String message,
}) {
  final overlay = Overlay.of(context);
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter, // ✅ ALWAYS TOP
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // 👈 auto width
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  // ⏱ Auto dismiss
  Future.delayed(const Duration(seconds: 1), () {
    entry.remove();
  });
}


  Future<void> fetchProductVariants() async {
    setState(() {
      isLoadingVariants = true;
    });

    try {
      final productId = widget.product.storeproductId;

      if (productId == null || productId == 0) {
        print("❌ Product ID is null or invalid");
        return;
      }

      final fetchedVariants =
          await ApiService.fetchVariantsList(productId);

      setState(() {
        variants = fetchedVariants;
        if (variants.isNotEmpty) {
          selectedVariant = variants.first;
        }
      });
    } catch (e) {
      print("⚠ Error fetching variants: $e");
    } finally {
      setState(() {
        isLoadingVariants = false;
      });
    }
  }

  Future<void> addToCart() async {
    if (selectedVariant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a product variant"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isAddingToCart = true;
    });

   final price =
    double.tryParse(
      selectedVariant?.discountedPrice ??
          selectedVariant?.regularPrice ??
          "0",
    ) ??
    0.0;


    final CartController cartController =
        Get.find<CartController>();

    await cartController.loadCart();

    final existingItem =
        cartController.cartItems.firstWhereOrNull(
      (item) =>
          item.storeProduct ==
              widget.product.storeproductId &&
          item.storeProductVariant ==
              selectedVariant!.variantId,
    );

    bool success = false;

    if (existingItem != null) {
      success = await ApiService.cartupdateURL(
        cartId: existingItem.cartId!,
        quantity: existingItem.quantity! + quantity,
        item: existingItem,
      );
    } else {
      success = await ApiService.addToCart(
        productId: widget.product.storeproductId!,
        variantId: selectedVariant!.variantId,
        quantity: quantity,
        price: price,
      );
    }

    setState(() {
      isAddingToCart = false;
    });

    await cartController.loadCart();

   if (success) {
  cartController.showBadgeAgain();
  cartController.hideCartBadge();

 showTopSingleLinePopup(
  message: "Added to cart",
);

} else {
  showTopSingleLinePopup(
  message: "Failed to add cart",
);
}

  }

void _shareProduct() async {
  final product = widget.product;


  final price =
      selectedVariant?.discountedPrice ??
      selectedVariant?.regularPrice ??
      product.regularPrice ??
      "0";

  final productId = product.storeproductId;

  final shareText = '''
🐾 ${product.productName}

${product.productShortDescription ?? product.productDescription ?? ""}

💰 Price: ₹$price

View product 👇
https://pawlli.app/product/$productId
''';

  await Share.share(shareText);
}

// ==========================
// PRODUCT DETAILS ROW
// ==========================
Widget _buildDetailRow(String title, String? value) {
  if (value == null || value.trim().isEmpty) {
    return const SizedBox(); // auto hide if empty
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final CartController cartController =
        Get.find<CartController>();

    final product = widget.product;

      final int availableStock =
          selectedVariant?.availableStock ?? 0;

      final bool isOutOfStock = availableStock <= 0;

      // ================= PRICE CALCULATION =================
  final double regularPriceValue =
      double.tryParse(selectedVariant?.regularPrice ?? '') ?? 0;

  final double discountedPriceValue =
      double.tryParse(selectedVariant?.discountedPrice ?? '') ?? 0;

  final bool hasDiscount =
      discountedPriceValue > 0 &&
      regularPriceValue > 0 &&
      discountedPriceValue < regularPriceValue;

  final double discountAmount =
      hasDiscount ? (regularPriceValue - discountedPriceValue) : 0;

  final int discountPercent =
      hasDiscount
          ? ((discountAmount / regularPriceValue) * 100).round()
          : 0;
  // ====================================================


    final String productName =
        product.productName ?? "Unnamed Product";

    final String? discountedPrice =
        product.discountedPrice;

    final String? regularPrice =
        product.regularPrice;

    final String productDescription =
        product.productDescription ?? "";

    final List<String> productImages =
        product.productImages != null &&
                product.productImages!.isNotEmpty
            ? product.productImages!
                .map((img) => img.toString())
                .toList()
            : [];

    final List<String> productTags =
        product.productFeatures ?? [''];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: isOutOfStock ? Colors.grey : Colours.primarycolour,

          ),
          onPressed: (isOutOfStock || isAddingToCart)
            ? null
            : addToCart,

          label: isAddingToCart
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  isOutOfStock ? 'OUT OF STOCK' : 'ADD TO CART',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

        ),
      ),
      body: Stack(
        children: [
          /// Top background image
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: screenWidth * 0.55,
              height: screenHeight * 0.10,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    Assets.images.topimage.path,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          /// Main content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
              AppBar(
                title: Text(
                  selectedVariant?.variantName != null
                      ? '${widget.product.productName} • ${selectedVariant!.variantName}'
                      : widget.product.productName ?? 'Product',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenHeight * 0.022,
                    fontWeight: FontWeight.w600,
                    color: Colours.brownColour,
                  ),
                ),
                foregroundColor: Colours.brownColour,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.ios_share),
                    onPressed: _shareProduct,
                  ),
                ],
              ),

                const SizedBox(height: 8),

                _ImageCard(
                  screenWidth: screenWidth,
                  imageUrls: (selectedVariant?.productImages.isNotEmpty ?? false)
                      ? selectedVariant!.productImages
                      : productImages,
                ),

                const SizedBox(height: 12),

                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                /// Variant selector
                isLoadingVariants
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : variants.isEmpty
                        ? const Text(
                            "No variants available",
                            style: TextStyle(
                                color: Colors.red),
                          )
                        : Wrap(
                            spacing: 8,
                            children:
                                variants.map((variant) {
                              final isSelected =
                                  selectedVariant
                                          ?.variantId ==
                                      variant.variantId;

                              return ChoiceChip(
                                label: Text(
                                  variant.variantName ??
                                      "Variant",
                                ),
                                selected:
                                    isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    selectedVariant = variant;
                                    _currentImageIndex = 0;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                const SizedBox(height: 12),

                 /// Price + Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Discount percent badge
                              if (hasDiscount)
                              Text(
                                '$discountPercent% OFF  ',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                              // ✅ MAIN PRICE
                              Text(
                                '₹ ${hasDiscount
                                    ? discountedPriceValue.toStringAsFixed(0)
                                    : regularPriceValue.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(width: 8),

                              // ✅ STRIKED REGULAR PRICE
                              if (hasDiscount)
                                Text(
                                  '₹ ${regularPriceValue.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),

                          // ✅ DISCOUNT INFO
                          if (hasDiscount)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'You save ₹${discountAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                 const SizedBox(width: 8),
                                if (isOutOfStock)
                                  const Text(
                                    "Out of stock",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                else if (availableStock <= 5)
                                  Text(
                                    "Only $availableStock left",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                        ],
                      ),

                      // 🔢 Quantity buttons (UNCHANGED)
                      Row(
                        children: [
                        _QuantityButton(
                            icon: Icons.remove,
                            onTap: isOutOfStock
                                ? () {}
                                : () => setState(
                                      () => quantity = quantity > 1 ? quantity - 1 : 1,
                                    ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              quantity.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isOutOfStock ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        _QuantityButton(
                            icon: Icons.add,
                            onTap: (isOutOfStock || quantity >= availableStock)
                                ? () {}
                                : () => setState(() => quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                Text(
                  productDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: productTags
                      .map(
                        (tag) =>
                            _TagChip(label: tag),
                      )
                      .toList(),
                ),

                const SizedBox(height: 24),

// ============================
// PRODUCT DETAILS SECTION
// ============================

const Text(
  "Product Details",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

// Product-level details
_buildDetailRow("Brand",  product.productBrand),
_buildDetailRow("Pet Type", product.petType),
_buildDetailRow("Age Group", product.ageGroup),

// Variant-level details (IMPORTANT)
_buildDetailRow(
  "Weight",
  selectedVariant?.productWeightKg,
),

_buildDetailRow(
  "Dimensions",
  selectedVariant?.productDimensionsCm,
),

_buildDetailRow(
  "SKU",
  selectedVariant?.variantSku,
),

const SizedBox(height: 20),



                const SizedBox(height: 30),
              ],
            ),
          ),
          /// 🛒 Floating cart icon
          Positioned(
            bottom: 5,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                cartController.hideCartBadge();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CartPage(),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Colours.primarycolour,
                      borderRadius:
                          BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Obx(() {
                    final count =
                        cartController.cartItems.length;

                    if (count == 0) {
                      return const SizedBox.shrink();
                    }

                    return Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        padding:
                            const EdgeInsets.all(5),
                        decoration:
                            const BoxDecoration(
                          color: Colors.red,
                          shape:
                              BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          count.toString(),
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// --- Image Card ---
class _ImageCard extends StatefulWidget {
  final double screenWidth;
  final List<String> imageUrls;

  const _ImageCard({
    Key? key,
    required this.screenWidth,
    required this.imageUrls,
  }) : super(key: key);

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15,
      color: Colours.secondarycolour,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: widget.imageUrls.isNotEmpty
            ? Column(
                children: [
                  SizedBox(
                    height: widget.screenWidth * 0.45,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImageViewer(
                                  images: widget.imageUrls,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            widget.imageUrls[index],
                            width: widget.screenWidth * 0.80,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔵 DOT INDICATOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.imageUrls.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentIndex == index ? 10 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? Colours.primarycolour
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: Icon(Icons.image, size: 60, color: Colors.grey),
              ),
      ),
    );
  }
}



// --- Quantity Button ---
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QuantityButton({Key? key, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: Colours.primarycolour, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// --- Tag Chip ---
class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colours.primarycolour,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colours.primarycolour),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController controller =
        PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.network(
                images[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
