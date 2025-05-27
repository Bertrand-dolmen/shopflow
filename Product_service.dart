import '../models/product.dart';

class ProductService {
  static List<Product> _products = [
    Product(
      id: '1',
      name: 'iPhone 15 Pro Max',
      price: 1199.99,
      description: 'Le smartphone le plus avancé d\'Apple avec puce A17 Pro, caméra révolutionnaire et design en titane premium.',
      category: 'Electronics',
      imageKeyword: 'modern premium smartphone titanium',
      imageType: 'photo',
      imageCategory: 'technology',
    ),
    Product(
      id: '2',
      name: 'MacBook Pro M3',
      price: 2499.99,
      description: 'Ordinateur portable professionnel avec puce M3, écran Liquid Retina XDR et performances exceptionnelles.',
      category: 'Electronics',
      imageKeyword: 'professional laptop computer silver',
      imageType: 'photo',
      imageCategory: 'technology',
    ),
    Product(
      id: '3',
      name: 'iPad Air',
      price: 699.99,
      description: 'Tablette polyvalente avec puce M1, écran Liquid Retina et compatibilité Apple Pencil.',
      category: 'Electronics',
      imageKeyword: 'modern tablet device sleek',
      imageType: 'photo',
      imageCategory: 'technology',
    ),
    Product(
      id: '4',
      name: 'AirPods Pro',
      price: 279.99,
      description: 'Écouteurs sans fil avec réduction de bruit active, son spatial et étui de charge MagSafe.',
      category: 'Audio',
      imageKeyword: 'wireless earphones white premium',
      imageType: 'photo',
      imageCategory: 'technology',
    ),
    Product(
      id: '5',
      name: 'Samsung Galaxy S24',
      price: 999.99,
      description: 'Smartphone Android flagship avec IA Galaxy, caméra 200MP et écran Dynamic AMOLED 2X.',
      category: 'Electronics',
      imageKeyword: 'android smartphone premium black',
      imageType: 'photo',
      imageCategory: 'technology',
    ),
    Product(
      id: '6',
      name: 'Sony WH-1000XM5',
      price: 399.99,
      description: 'Casque audio haut de gamme avec réduction de bruit leader du marché et autonomie 30h.',
      category: 'Audio',
      imageKeyword: 'premium headphones black wireless',
      imageType: 'photo',
      imageCategory: 'technology',
    ),
    Product(
      id: '7',
      name: 'Nintendo Switch',
      price: 349.99,
      description: 'Console de jeu hybride pour jouer à la maison et en déplacement avec Joy-Con détachables.',
      category: 'Gaming',
      imageKeyword: 'gaming console portable colorful',
      imageType: 'photo',
      imageCategory: 'technology',
    ),
    Product(
      id: '8',
      name: 'Tesla Model S',
      price: 89999.99,
      description: 'Berline électrique de luxe avec autonomie 650km, Autopilot et accélération 0-100 en 2,1s.',
      category: 'Automotive',
      imageKeyword: 'luxury electric car modern sleek',
      imageType: 'photo',
      imageCategory: 'transportation',
    ),
  ];

  static List<Product> getAllProducts() => _products;

  static Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    return _products.where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()) ||
        product.description.toLowerCase().contains(query.toLowerCase()) ||
        product.category.toLowerCase().contains(query.toLowerCase())).toList();
  }

  static List<Product> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products.where((product) => product.category == category).toList();
  }

  static List<String> getCategories() {
    Set<String> categories = {'All'};
    categories.addAll(_products.map((product) => product.category));
    return categories.toList();
  }

  static List<Product> filterProducts(String searchQuery, String category) {
    List<Product> filtered = _products;
    
    if (category != 'All') {
      filtered = filtered.where((product) => product.category == category).toList();
    }
    
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) =>
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    
    return filtered;
  }
}
