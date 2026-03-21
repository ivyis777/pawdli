import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/storeproductcontroller.dart';
import 'package:pawlli/data/controller/storesearchcontroller.dart';
import 'package:pawlli/presentation/screens/pet store/pet_storeproduct.dart';
import 'package:pawlli/presentation/screens/pet store/store_categaries.dart';

class StoreSearchPage extends StatelessWidget {
  StoreSearchPage({super.key});

  // ✅ Move controller outside build
  final StoreSearchController controller =
      Get.isRegistered<StoreSearchController>()
          ? Get.find<StoreSearchController>()
          : Get.put(StoreSearchController());

  final TextEditingController textController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        titleSpacing: 0,
        title: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colours.brownColour,
                onPressed: () =>
                    Navigator.pop(context),
              ),

              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    controller: textController,
                    autofocus: true,

                    onChanged: (value) {
                      controller.onSearchChanged(value);
                    },

                    onSubmitted: (value) async {
                      final query = value.trim();

                      if (query.isEmpty) return;

                      // 🔥 Call search once
                      await controller.searchProducts(query);

                      // ✅ ADD THIS BLOCK 👇 (IMPORTANT FIX)
                      final productController = Get.find<StoreProductController>();

                      productController.productList.assignAll(controller.products);
                      productController.filteredList.assignAll(controller.products);

                      productController.productList.refresh();
                      productController.filteredList.refresh();

                      // 🔥 KEEP YOUR EXISTING RECENT SEARCH CODE (NO CHANGE)

                      if (controller.products.isNotEmpty) {
                        String image = "";

                        final lowerQuery = query.toLowerCase();

                        final matchedProduct = controller.products.firstWhere(
                          (p) =>
                              (p.productName ?? "").toLowerCase().contains(lowerQuery) ||
                              (p.petType ?? "").toLowerCase().contains(lowerQuery) ||
                              (p.productBrand ?? "").toLowerCase().contains(lowerQuery),
                          orElse: () => controller.products.first,
                        );

                        if (matchedProduct.productImages != null &&
                            matchedProduct.productImages!.isNotEmpty) {
                          image = matchedProduct.productImages!.first;
                        }

                        final alreadyExists = controller.recentSearches
                            .any((e) => e["query"] == query);

                        if (!alreadyExists) {
                          controller.recentSearches.insert(0, {
                            "query": query,
                            "image": image,
                          });

                          if (controller.recentSearches.length > 5) {
                            controller.recentSearches.removeLast();
                          }
                        }
                      }

                      // ✅ NAVIGATION (UNCHANGED)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            searchQuery: query,
                          ),
                        ),
                      );
                    },

                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          Colours.seachbarcolour,
                      hintText: "Search products...",

                      prefixIcon: Icon(
                        Icons.search,
                        color: Colours.textColour,
                      ),

                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: textController,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) return const SizedBox();

                          return IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              textController.clear();
                              controller.products.clear();
                            },
                          );
                        },
                      ),

                      contentPadding:
                          const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 15),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color:
                              Colours.primarycolour,
                        ),
                      ),

                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color:
                              Colours.primarycolour,
                        ),
                      ),

                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color:
                              Colours.primarycolour,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            /// 🔥 RECENT SEARCHES
            Obx(() {
              if (controller
                  .recentSearches.isEmpty) {
                return const SizedBox();
              }

              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      const Text(
                        "Recent Searches",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          controller
                              .recentSearches
                              .clear();
                        },
                        child: Text(
                          "Clear",
                          style: TextStyle(
                            color: Colours
                                .primarycolour,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection:
                          Axis.horizontal,
                      itemCount: controller
                          .recentSearches
                          .length,
                      itemBuilder:
                          (context, index) {
                        final item = controller
                            .recentSearches[index];
                        final query =
                            item["query"] ?? "";
                        final image =
                            item["image"] ?? "";

                        return GestureDetector(
                          onTap: () {
                            textController.text = query;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductListScreen(
                                  searchQuery: query,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(
                                    right: 12),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      Colours
                                          .primarycolour
                                          .withOpacity(
                                              0.1),
                                  child: Icon(
                                    Icons.pets,
                                    color: Colours
                                        .primarycolour,
                                    size: 28,
                                  ),
                                ),

                                const SizedBox(
                                    height: 6),

                                Text(
                                  query,
                                  style:
                                      const TextStyle(
                                          fontSize:
                                              13),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              );
            }),

            /// 🔥 PRODUCT LIST + LOADING
            Expanded(
              child: Obx(() {
                // 🔹 Loading
                if (controller.isLoading.value) {
                  return const Center(
                      child:
                          CircularProgressIndicator());
                }

                // 🔹 No input
                if (textController.text.isEmpty) {
                  return const Center(
                    child: Text(
                      " ",
                      style:
                          TextStyle(fontSize: 16),
                    ),
                  );
                }

                // 🔹 No results
                if (controller.products.isEmpty) {
                  return const Center(
                    child: Text(
                      "No products found",
                      style:
                          TextStyle(fontSize: 16),
                    ),
                  );
                }

                // 🔹 Product List
                return ListView.builder(
                  itemCount:
                      controller.products.length,
                  itemBuilder:
                      (context, index) {
                    final p =
                        controller.products[index];

                    String image = "";

                    if (p.productImages != null &&
                        p.productImages!
                            .isNotEmpty) {
                      image =
                          p.productImages!.first;
                    }

                    return Column(
                      children: [
                        ListTile(
                          leading: image.isNotEmpty
                              ? Image.network(
                                  image,
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.contain,
                                )
                              : const Icon(
                                  Icons.search,
                                  size: 28),

                          title: Text(
                            p.productName ?? '',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),

                          subtitle: p.petType != null
                              ? Text(
                                  "in ${p.petType}",
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.blue,
                                    fontSize: 13,
                                  ),
                                )
                              : null,

                          trailing: const Icon(
                            Icons.north_west,
                            size: 20,
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsScreen(
                                        product: p),
                              ),
                            );
                          },
                        ),

                        const Divider(height: 1),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}