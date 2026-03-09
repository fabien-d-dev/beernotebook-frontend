class Beer {
  final int id;
  final String brand;
  final String? productId;
  final String? genericName;
  final String? type;
  final String? abv;
  final String? quantity;
  final String? imageUrl;
  final String? manufacturingPlace;
  final String? allergens;
  final String? ingredients;
  final String? hops;
  final double? globalRating;

  Beer({
    required this.id,
    required this.brand,
    this.productId,
    this.genericName,
    this.type,
    this.abv,
    this.quantity,
    this.imageUrl,
    this.manufacturingPlace,
    this.allergens,
    this.ingredients,
    this.hops,
    this.globalRating,
  });

  factory Beer.fromJson(Map<String, dynamic> json) {
    return Beer(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      brand: json['brand'] ?? 'Marque inconnue',
      productId: json['product_id']?.toString(),
      genericName: json['generic_name'] ?? json['product_name'],
      type: json['type'],
      abv: json['abv']?.toString(),
      quantity: json['quantity']?.toString(),
      imageUrl: json['image_url']?.toString(),
      manufacturingPlace: json['manufacturing_place']?.toString(),
      allergens: json['allergens']?.toString(),
      ingredients: json['ingredients']?.toString(),
      hops: json['hops']?.toString(),
    );
  }

  String get formattedQuantity {
    if (quantity == null || quantity!.isEmpty) return "--";
    final double? ml = double.tryParse(quantity!);
    if (ml == null) return quantity!;
    if (ml >= 1000) return "${(ml / 1000).toStringAsFixed(0)} L";
    return "${(ml / 10).toStringAsFixed(0)} cl";
  }
}
