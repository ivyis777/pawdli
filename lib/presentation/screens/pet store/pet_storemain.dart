import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/PetStoreCategariesController.dart';
import 'package:pawlli/data/controller/cartviewcontroller.dart';
import 'package:pawlli/data/controller/petstorecatigeriescontroller.dart';
import 'package:pawlli/data/controller/storeproductcontroller.dart';
import 'package:pawlli/data/controller/storepromotioncontroller.dart';
import 'package:pawlli/data/model/petstoresubcategaries.dart';
import 'package:pawlli/data/model/storeprocductmodel.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/pet%20store/pet_cart.dart';
import 'package:pawlli/presentation/screens/pet%20store/store_categaries.dart';
import 'package:pawlli/presentation/screens/pet%20store/storesearchpage.dart';

class PetstorePage extends StatefulWidget {
  const PetstorePage({super.key});

  @override
  State<PetstorePage> createState() => _PetstorePageState();
}

class _PetstorePageState extends State<PetstorePage> {
  final StoreProductController storeProductController = Get.put(StoreProductController());

  // final TextEditingController _searchController = TextEditingController();

  final PetStoreCategoryController _categoryController = Get.put(PetStoreCategoryController());
  final PetStoreController _subCategoryController = Get.put(PetStoreController());
  final Storepromotioncontroller promotionController = Get.put(Storepromotioncontroller(), permanent: true);

  List<SubCategoryData> _allSubCategories = [];
  // List<SubCategoryData> _filteredSubCategories = [];

  List<StoreProductData> _allProducts = [];
  // List<Data> _filteredProducts = [];

  // bool _isSearching = false;

  int _selectedCategoryIndex = 0;

  // late PageController _pageController;

  int _categoryHintIndex = 0;
  List<String> categoryHints = [];
  Timer? _hintTimer;

  // Timer? _searchDebounce;

  // Map category names to images
  final Map<String, String> categoryImages = {
    'Cloths': 'assets/icons/cloths.png',
    'Accessories': 'assets/icons/accessories.png',
    'Food': 'assets/icons/food.png',
    'Grooming': 'assets/icons/Grooming.png',
    'Toys': 'assets/icons/Toys.png',
    'Unknown': 'assets/icons/default.png',
  };

  // -------------------------------
  // Lifecycle
  // -------------------------------
  @override
  void initState() {
    super.initState();

    // _pageController = PageController(initialPage: 0);

    // _searchController.addListener(() {
    //   setState(() {});
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    // _searchDebounce?.cancel();
    // _searchController.dispose();
    super.dispose();
  }

  // -------------------------------
  // Initial Data
  // -------------------------------
  Future<void> loadInitialData() async {
    await _categoryController.loadCategories();

    if (_categoryController.categories.isNotEmpty) {
      categoryHints = _categoryController.categories.map((e) => e.name ?? '').toList();

      _hintTimer?.cancel();
      _hintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted || categoryHints.isEmpty) {
          timer.cancel();
          return;
        }

        setState(() {
          _categoryHintIndex = (_categoryHintIndex + 1) % categoryHints.length;
        });
      });

      final firstCategoryId = _categoryController.categories[0].storeCategoryId ?? 1;

      await _subCategoryController.loadSubCategories(firstCategoryId);
      await _loadAllSubCategories();
      await _loadAllProducts();
    }
  }

  Future<void> _loadAllSubCategories() async {
    _allSubCategories.clear();

    for (final category in _categoryController.categories) {
      final catId = category.storeCategoryId;
      if (catId == null) continue;

      final tempController = PetStoreController();
      await tempController.loadSubCategories(catId);
      _allSubCategories.addAll(tempController.subCategories);
    }
  }

  Future<void> _loadAllProducts() async {
    _allProducts.clear();

    for (final sub in _allSubCategories) {
      final subId = sub.storeSubcategoryId;
      if (subId == null) continue;

      final products = await ApiService.fetchProducts(subId);
      _allProducts.addAll(products);
    }
  }

  Widget _buildSearchBar() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colours.seachbarcolour,
          ),
        ),
        child: TextField(
          readOnly: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>  StoreSearchPage(),
              ),
            );
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colours.seachbarcolour,
            hintText: categoryHints.isEmpty ? '' : 'Paw ${categoryHints[_categoryHintIndex]}',
            hintStyle: TextStyle(
              color: Colours.textColour,
              fontFamily: FontFamily.Cairo,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(Icons.search, color: Colours.textColour),
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Colours.primarycolour, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Colours.primarycolour, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Colours.primarycolour, width: 1.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBarCollapsed() {
    return TextField(
      readOnly: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>  StoreSearchPage(),
          ),
        );
      },
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colours.primarycolour, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colours.primarycolour, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colours.primarycolour, width: 1.0),
        ),
        filled: true,
        fillColor: Colours.seachbarcolour,
        hintText: categoryHints.isEmpty ? '' : 'Paw ${categoryHints[_categoryHintIndex]}',
        prefixIcon: const Icon(Icons.search, size: 20),
      ),
    );
  }

  Widget _buildCategorySection({bool isCollapsed = false}) {
    return Obx(() {
      return SizedBox(
        height: isCollapsed ? 60 : 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categoryController.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final category = _categoryController.categories[index];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });

                _subCategoryController.loadSubCategories(category.storeCategoryId ?? 1);
              },
              child: isCollapsed
                  ? _buildCategoryNameOnly(
                      category.name ?? '',
                      _selectedCategoryIndex == index,
                    )
                  : _buildCategoryItem(
                      categoryImages[category.name] ?? categoryImages['Unknown']!,
                      category.name ?? '',
                      _selectedCategoryIndex == index,
                      isCollapsed,
                    ),
            );
          },
        ),
      );
    });
  }

  // (Rest of your code continues EXACTLY same…)
    @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// ✅ YOUR ORIGINAL SCROLL VIEW (UNCHANGED)
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: Colours.brownColour,
                elevation: 0,
                toolbarHeight: 80,
                title: SizedBox(
                  height: 45,
                  child: _buildSearchBarCollapsed(),
                ),
                centerTitle: true,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryDelegate(
                  builder: (isCollapsed) =>
                      _buildCategorySection(isCollapsed: isCollapsed),
                ),
              ),

              // if (!_isSearching)
              const SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildProductsForCategory(),
                ),
              ),
            ],
          ),

          /// ✅ CART ICON FIXED OVERLAY
          // if (!_isSearching)
          Positioned(
            bottom: 5,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                cartController.hideCartBadge();
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  /// CART BUTTON
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
                      size: 28,
                    ),
                  ),

                  /// 🔴 BADGE
                  Obx(() {
                    final count = cartController.cartItems.length;

                    if (count == 0) {
                      return const SizedBox.shrink();
                    }

                    return Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
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
        ],
      ),
    );
  }

  // Helpers
  Widget _buildCategoryItem(
    String imagePath,
    String categoryName,
    bool isSelected,
    bool isCollapsed,
  ) {
    return SizedBox(
      width: 100,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: constraints.maxHeight * 0.8,
                width: constraints.maxHeight * 0.8,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colours.primarycolour : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

Widget _buildCategoryNameOnly(String name, bool isSelected) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Center(
      child: Container(
        // padding: const EdgeInsets.symmetric(
          width: 120,
          height: 40,
        // ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? Colours.primarycolour
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black, // ✅ better contrast
          ),
        ),
      ),
    ),
  );
}

  Widget _buildProductsForCategory() {
    return Obx(() {
      if (_subCategoryController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_subCategoryController.errorMessage.isNotEmpty) {
        return Center(child: Text(_subCategoryController.errorMessage.value));
      }

      final subs = _subCategoryController.subCategories;

      if (subs.isEmpty) {
        return const Center(child: Text('No subcategories available'));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subs.map((sub) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(sub.name ?? 'Unnamed'),
              const SizedBox(height: 8),
              _horizontalProductList(sub),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      );
    });
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _horizontalProductList(SubCategoryData sub) {
    return SizedBox(
      height: 200,
      width: 450,
      child: GestureDetector(
        onTap: () {
          final subId = sub.storeSubcategoryId;
          if (subId == null) return;

          storeProductController.selectedSubCategoryName.value =
              sub.name ?? 'No Name';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductListScreen(
                storeSubcategoryId: subId,
              ),
            ),
          );
        },
        child: _buildProductCard(sub.imageUrl ?? ''),
      ),
    );
  }

  Widget _buildProductCard(String rawImageUrl) {
    String cleanUrl(String raw) {
      if (raw.isEmpty) return '';

      if (raw.contains('https%3A')) {
        final index = raw.indexOf('media/');
        if (index != -1) raw = raw.substring(index);
      }
      return raw;
    }

    final imageUrl = cleanUrl(rawImageUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(255, 232, 192, 132),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Colors.white,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.pets, size: 50, color: Colors.grey),
                  ),
                )
              : const Center(
                  child: Icon(Icons.pets, size: 50, color: Colors.grey),
                ),
        ),
      ),
    );
  }
}

class _CategoryDelegate extends SliverPersistentHeaderDelegate {
  final Widget Function(bool isCollapsed) builder;

  _CategoryDelegate({required this.builder});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 150;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isCollapsed = shrinkOffset >= (maxExtent - minExtent);
    final currentHeight =
        (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);

    return ClipRect(
  child: Align(
    alignment: Alignment.bottomCenter, // 🔥 important
    child: SizedBox(
      height: currentHeight,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(bottom: 6), // 🔥 fix cut text
        child: builder(isCollapsed),
      ),
    ),
  ),
);
  }

  @override
  bool shouldRebuild(
          covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}