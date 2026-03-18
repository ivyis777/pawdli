import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/model/ordermodel.dart';
import 'package:pawlli/presentation/screens/pet store/pet_cart.dart';

class ReorderScreen extends StatefulWidget {
  final Order order;

  const ReorderScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends State<ReorderScreen> {
  int quantity = 1;
  late Order order;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final item = order.items.isNotEmpty ? order.items.first : null;

    // No item found safety
    if (item == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Reorder Item"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colours.brownColour,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            "No items found for reorder!",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
      );
    }

    // Correct new fields
    final title = item.productName;
    final imageUrl = item.productImages.isNotEmpty
        ? item.productImages.first
        : (item.variantImages.isNotEmpty ? item.variantImages.first : null);

    final price = item.price;

    return Scaffold(
      backgroundColor: Colors.white,

      // -------------------- Bottom Button --------------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: Colors.white,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colours.primarycolour,
          ),
          onPressed: () {
            // TODO → Add this item into the cart in future
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
          },
          label: const Text(
            'Reorder',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
      ),

      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.55,
              height: screenHeight * 0.10,
              color: Colours.secondarycolour.withOpacity(0.2),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -------------------- AppBar --------------------
                AppBar(
                  title: Text(
                    'Reorder Item',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.w600,
                      color: Colours.brownColour,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                const SizedBox(height: 8),

                // -------------------- IMAGE --------------------
                Card(
                  elevation: 8,
                  color: Colours.secondarycolour,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              height: 160,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) =>
                                  Image.asset("assets/images/noimage.png",
                                      height: 160),
                            )
                          : Image.asset("assets/images/noimage.png",
                              height: 160),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // -------------------- TITLE --------------------
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),

                // -------------------- PRICE & QUANTITY --------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹ ${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.remove,
                          onTap: () => setState(() {
                            quantity = quantity > 1 ? quantity - 1 : 1;
                          }),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add,
                          onTap: () => setState(() => quantity++),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // -------------------- ORDER STATUS --------------------
                Text(
                  order.orderStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colours.primarycolour,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colours.primarycolour,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
