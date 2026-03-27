import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/store_like.dart';
import 'package:pawlli/data/controller/cartviewcontroller.dart';
import 'package:pawlli/data/controller/storeproductcontroller.dart';
import 'package:pawlli/data/controller/storesearchcontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/pet store/pet_storeproduct.dart';
import 'package:pawlli/presentation/screens/pet%20store/pet_cart.dart';

class ProductListScreen extends StatefulWidget {
  final int? storeSubcategoryId;
  final String? searchQuery;

  const ProductListScreen({Key? key, this.storeSubcategoryId,this.searchQuery,}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final StoreProductController controller = Get.find<StoreProductController>();
  final StoreProductController storeProductController = Get.find();
  final StoreSearchController searchController = Get.find<StoreSearchController>(); // ✅ ADD THIS
  String selectedSort = "Popular";

  final List<String> sortOptions = [
    "Popular",
    "Newest",
    "Customer Review",
    "Price: High to Low",
    "Price: Low to High",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.storeSubcategoryId != null) {
      controller.loadProducts(widget.storeSubcategoryId!);
    }
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[300],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Center(
              child: Text("Sort By",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            ...sortOptions.map((option) {
              final isSelected = selectedSort == option;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedSort = option);
                  controller.sortProducts(option);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colours.primarycolour : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(option,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? Colors.white : Colors.black,
                      )),
                ),
              );
            }).toList(),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
       final CartController cartController = Get.find<CartController>();


    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: screenWidth * 0.55,
              height: screenHeight * 0.10,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.images.topimage.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  title: Text(
                    widget.searchQuery != null && widget.searchQuery!.isNotEmpty
                        ? widget.searchQuery!   // ✅ SHOW SEARCH TEXT
                        : (storeProductController.selectedSubCategoryName.value.isEmpty
                            ? "Products"
                            : storeProductController.selectedSubCategoryName.value),
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.w600,
                      color: Colours.brownColour,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colours.brownColour,
                  elevation: 0,
                ),

                /// Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: controller.search,
                    decoration: InputDecoration(
                      hintText: 'Search for Products',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colours.textColour,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colours.seachbarcolour,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 15,
                      ),

                      // 🔥 DEFAULT BORDER
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Colours.primarycolour,
                          width: 1.5,
                        ),
                      ),

                      // 🔥 FOCUSED BORDER
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Colours.primarycolour,
                          width: 2,
                        ),
                      ),

                      // 🔥 ERROR BORDER (optional but recommended)
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),

                      // 🔥 DISABLED BORDER (optional)
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Colours.primarycolour.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                // const SizedBox(height: 15),
                // // promotion slider
                // Productpromotion(),

                const SizedBox(height: 30),

                /// Sort Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    const Text("Sort by:",
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 5),
                    Text(selectedSort,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colours.primarycolour,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(
                      icon: CircleAvatar(
                        backgroundColor: Colors.grey[50],
                        child: const Icon(Icons.filter_list, color: Colors.black),
                      ),
                      onPressed: _openSortSheet,
                    ),
                  ]),
                ),

                /// Product list
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: widget.searchQuery != null
                      ? searchController.products.length
                      : controller.filteredList.length,

                  itemBuilder: (context, index) {

                    final p = widget.searchQuery != null
                        ? searchController.products[index]
                        : controller.filteredList[index];

                    final bool isOutOfStock = p.isOutOfStock ?? false;

                    final image =
                        p.productImages?.isNotEmpty == true ? p.productImages!.first : "";

                    // ✅ CHEAPEST VARIANT PRICE
                    final cheapest = p.cheapestVariant;

                    final double sellingPriceValue =
                        cheapest?.discountedPrice ??
                        cheapest?.regularPrice ??
                        0;

                    final double regularPriceValue =
                        cheapest?.regularPrice ?? 0;

                    final bool hasDiscount =
                        cheapest?.discountedPrice != null &&
                        cheapest!.discountedPrice! < regularPriceValue;

                    final int discountPercent =
                        hasDiscount
                            ? (((regularPriceValue - sellingPriceValue) /
                                    regularPriceValue) *
                                100)
                                .round()
                            : 0;

                    final String sellingPrice =
                        sellingPriceValue.toStringAsFixed(0);

                    return _buildProductCard(
                      image,
                      p.productName ?? "",
                      p.petType ?? "",
                      sellingPrice,
                      p.isFeatured == true ? "⭐ Featured" : "⭐ Popular",
                      productId: p.storeproductId,
                      regularPrice: regularPriceValue.toStringAsFixed(0),
                      hasDiscount: hasDiscount && !isOutOfStock,
                      discountPercent: discountPercent,
                      isOutOfStock: isOutOfStock,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(product: p),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          /// 🛒 Fixed cart icon (does not scroll)
            Positioned(
              bottom: 5,
              right: 20,
              child: GestureDetector(
                onTap: () async {
                  // Hide badge when cart opens
                  cartController.hideCartBadge();

                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colours.primarycolour,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    // 🔴 CART COUNT BADGE
                    Obx(() {
              final count = cartController.cartItems.length;

              // 🧪 DEBUG LOG
              debugPrint(
                "🛒 CART BADGE DEBUG → count=$count"
              );

              if (count == 0) {
                debugPrint("❌ Badge hidden (cart is empty)");
                return const SizedBox.shrink();
              }

              debugPrint("✅ Badge visible (count=$count)");

              return Positioned(
                top: -1,
                right: -1,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20, 
                    minHeight: 20,
                  ),
                  child: Text(
                    count.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
      ],
    ),
  ),
),
        ]);
      }),
    );
    
  }


  Widget _buildProductCard(
    String image,
    String title,
    String category,
    String price,
    String rating, {
    required int? productId,
    String? regularPrice,
    bool hasDiscount = false,
    int discountPercent = 0,
    bool isOutOfStock = false, // 🔥 ADD
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(clipBehavior: Clip.none, children: [
          /// BOTTOM CARD
          Card(
            color: Colours.primarycolour,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.only(top: 150),
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 400,
                maxWidth: 400,
                minHeight: 140,
                maxHeight: 140,
              ),
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colours.black)),
                  SizedBox(height: 5),
                  Text(category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colours.secondarycolour,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          /// IMAGE CARD
          Card(
            color: Colours.secondarycolour,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: image.isNotEmpty
                  ? Opacity(
                    opacity: isOutOfStock ? 0.4 : 1.0,
                    child: Image.network(
                      image,
                      height: 180,
                      width: 360,
                      fit: BoxFit.contain,
                    ),
                  )
                  : const Icon(Icons.pets, size: 60, color: Colors.grey),
            ),
          ),

          /// 🚫 OUT OF STOCK BADGE
          if (isOutOfStock)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "OUT OF STOCK",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          /// 🔥 DISCOUNT BADGE (TOP LEFT)
            if (hasDiscount && discountPercent > 0)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "$discountPercent% OFF",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

          /// ❤️ Like icon
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.transparent,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: _AnimatedHeart(
                key: ValueKey(productId),
                productId: productId,
              ),

            ),
          ),

          /// ⭐ Floating price tag
          Positioned(
            top: 165,
            right: 0,
            child: Card(
              color: Colors.brown,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Row(children: [
                  if (hasDiscount && regularPrice != null)
                    Text(
                      "₹$regularPrice ",
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.lineThrough, decorationColor: Colors.white,
                        decorationThickness: 1,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  Text(
                    "₹$price",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  )
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// ❤️ Like Button with persistent storage
class _AnimatedHeart extends StatefulWidget {
  final int? productId;
  const _AnimatedHeart({Key? key, this.productId}) : super(key: key);

  @override
  State<_AnimatedHeart> createState() => _AnimatedHeartState();
}

class _AnimatedHeartState extends State<_AnimatedHeart>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

      final id = widget.productId;
      isLiked = id != null ? LikeStorage.isLiked(id) : false;
  }

  void _toggleLike() {
    final id = widget.productId;
    if (id == null) return;

    setState(() => isLiked = !isLiked);
    LikeStorage.toggleLike(id);
    _controller.forward(from: 0);
  }


  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.3)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
      child: GestureDetector(
        onTap: _toggleLike,
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? const Color.fromARGB(208, 244, 67, 54) : const Color.fromARGB(190, 212, 207, 207),
          size: 20,
        ),
      ),
    );
  }
}
