class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final String imageKeyword;
  final String imageType;
  final String imageCategory;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.imageKeyword,
    required this.imageType,
    required this.imageCategory,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'category': category,
        'imageKeyword': imageKeyword,
        'imageType': imageType,
        'imageCategory': imageCategory,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: json['price'].toDouble(),
        description: json['description'],
        category: json['category'],
        imageKeyword: json['imageKeyword'],
        imageType: json['imageType'],
        imageCategory: json['imageCategory'],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
