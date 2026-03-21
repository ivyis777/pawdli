class StoreSearchResponse {
  final bool? status;
  final String? message;
  final List<SearchProduct>? data;

  StoreSearchResponse({
    this.status,
    this.message,
    this.data,
  });

  factory StoreSearchResponse.fromJson(
      Map<String, dynamic> json) {
    return StoreSearchResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? List<SearchProduct>.from(
              json['data']
                  .map((x) =>
                      SearchProduct.fromJson(x)))
          : [],
    );
  }
}

class SearchProduct {
  final int? id;
  final String? productName;
  final String? image;

  SearchProduct({
    this.id,
    this.productName,
    this.image,
  });

  factory SearchProduct.fromJson(
      Map<String, dynamic> json) {
    return SearchProduct(
      id: json['storeproduct_id'],
      productName: json['product_name'],
      image: json['image'],
    );
  }
}