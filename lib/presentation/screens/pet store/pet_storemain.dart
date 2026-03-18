// import 'dart:async';
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
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/pet%20store/pet_cart.dart';
import 'package:pawlli/presentation/screens/pet%20store/pet_storeproduct.dart';
import 'package:pawlli/presentation/screens/pet%20store/store_categaries.dart';
import 'package:pawlli/presentation/widgets/promotions/storemainpromotion.dart';

class PetstorePage extends StatefulWidget {
  const PetstorePage({super.key});

  @override
  State<PetstorePage> createState() => _PetstorePageState();
}

class _PetstorePageState extends State<PetstorePage> {
  final StoreProductController storeProductController =
      Get.put(StoreProductController());
  final TextEditingController _searchController = TextEditingController();

  final PetStoreCategoryController _categoryController =
      Get.put(PetStoreCategoryController());
  final PetStoreController _subCategoryController =
      Get.put(PetStoreController());

      final Storepromotioncontroller promotionController =
    Get.put(Storepromotioncontroller(), permanent: true);


  List<SubCategoryData> _allSubCategories = [];
  List<SubCategoryData> _filteredSubCategories = [];
  List<Data> _allProducts = [];
  List<Data> _filteredProducts = [];

  bool _isSearching = false;

  int _selectedCategoryIndex = 0;
  late PageController _pageController;

  int _categoryHintIndex = 0;
  List<String> categoryHints = [];
  Timer? _hintTimer;
  Timer? _searchDebounce;


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
    _pageController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _searchDebounce?.cancel();
    // _searchController.dispose();
    super.dispose();
  }

  // -------------------------------
  // Initial Data
  // -------------------------------

  Future<void> loadInitialData() async {
    await _categoryController.loadCategories();

    if (_categoryController.categories.isNotEmpty) {
      categoryHints = _categoryController.categories
          .map((e) => e.name ?? '')
          .toList();

      _hintTimer?.cancel();
      _hintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted || categoryHints.isEmpty) {
          timer.cancel();
          return;
        }
        setState(() {
          _categoryHintIndex =
              (_categoryHintIndex + 1) % categoryHints.length;
        });
      });

      final firstCategoryId =
          _categoryController.categories[0].storeCategoryId ?? 1;

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

  // -------------------------------
  // Search
  // -------------------------------

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final q = query.trim().toLowerCase();

      if (q.isEmpty) {
        setState(() {
          _isSearching = false;
          _filteredSubCategories.clear();
          _filteredProducts.clear();
        });
        return;
      }

      setState(() {
        _isSearching = true;

        _filteredSubCategories = _allSubCategories
            .where((sub) =>
                (sub.name ?? '').toLowerCase().contains(q))
            .toList();

        _filteredProducts = _allProducts
            .where((product) =>
                (product.productName ?? '').toLowerCase().contains(q))
            .toList();
      });
    });
  }


  // -------------------------------
  // UI
  // -------------------------------

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top background image
          Positioned(
            top: 0.1,
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

          // Main content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  title: Text(
                    'Pet Store',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.w600,
                      color: Colours.brownColour,
                    ),
                  ),
                  foregroundColor: Colours.brownColour,
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: Colours.seachbarcolour, // stays same on focus
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      cursorColor: Colours.textColour,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        hintStyle: TextStyle(
                          color: Colours.textColour,
                          fontFamily: FontFamily.Cairo,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                        hintText: categoryHints.isEmpty
                            ? ''
                            : 'Paw ${categoryHints[_categoryHintIndex]}',
                        prefixIcon: Icon(Icons.search, color: Colours.textColour),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                color: Colours.textColour,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _isSearching = false;
                                    _filteredSubCategories.clear();
                                    _filteredProducts.clear();
                                  });
                                },
                              )
                            : null,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              BorderSide(color: Colours.primarycolour, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              BorderSide(color: Colours.primarycolour, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              BorderSide(color: Colours.primarycolour, width: 1.0),
                        ),
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 20),

                // Promotion
                if (!_isSearching) ...[
                  Storemainpromotion(),
                  const SizedBox(height: 30),
                ],

                // Categories
                if (!_isSearching)
                  Obx(() {
                    if (_categoryController.isLoading.value) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (_categoryController.categories.isEmpty) {
                      return const Center(
                          child: Text('No categories available'));
                    }

                    return SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categoryController.categories.length,
                        itemBuilder: (context, index) {
                          final category =
                              _categoryController.categories[index];

                          return GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _selectedCategoryIndex = index;
                                _isSearching = false;
                              });

                              _subCategoryController.loadSubCategories(
                                  category.storeCategoryId ?? 1);
                            },
                            child: _buildCategoryItem(
                              categoryImages[category.name] ??
                                  categoryImages['Unknown']!,
                              category.name ?? 'Unknown',
                              _selectedCategoryIndex == index,
                            ),
                          );
                        },
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                // Products / Subcategories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildProductsForCategory(),
                ),
              ],
            ),
          ),

          // Floating cart
          if (!_isSearching)
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
                  Container(
                    padding: const EdgeInsets.all(12),
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
                    child: const Icon(Icons.shopping_cart,
                        color: Colors.white, size: 30),
                  ),
                  Obx(() {
                    final count = cartController.cartItems.length;
                    if (count == 0) return const SizedBox.shrink();

                    return Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Text(
                          count.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
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

  // -------------------------------
  // Helpers
  // -------------------------------

  Widget _buildCategoryItem(
    String imagePath,
    String categoryName,
    bool isSelected,
  ) {
    return SizedBox(
      height: 300,
      width: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colours.primarycolour : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              imagePath,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            categoryName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsForCategory() {
    if (_isSearching) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_filteredSubCategories.isNotEmpty) ...[
            const SizedBox(height: 10),
            ..._filteredSubCategories.map((sub) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub.name ?? 'Unnamed Subcategory',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _horizontalProductList(sub),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
          if (_filteredProducts.isNotEmpty) ...[
            const SizedBox(height: 10),
            // Text(_searchController.text,
            //     style: const TextStyle(
            //         fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._filteredProducts.map(_buildSearchProductItem),
          ],
        ],
      );
    }

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

  Widget _buildSearchProductItem(Data product) {
    final imageUrl =
        (product.productImages != null && product.productImages!.isNotEmpty)
            ? product.productImages!.first
            : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.pets, size: 40),
                    )
                  : const Icon(Icons.pets, size: 40),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                product.productName ?? 'Unnamed Product',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
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
              builder: (_) => ProductListScreen(storeSubcategoryId: subId),
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
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
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
                      child: Icon(Icons.pets, size: 50, color: Colors.grey)),
                )
              : const Center(
                  child: Icon(Icons.pets, size: 50, color: Colors.grey)),
        ),
      ),
    );
  }
}
