import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'product_details_page.dart';
import 'cart_page.dart';
import '../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<Product> _filteredProducts = [];
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _filteredProducts = ProductService.getAllProducts();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    
    // Load cart data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartService>().loadCart();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = ProductService.filterProducts(
        _searchController.text,
        _selectedCategory,
      );
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              title: Text(
                '🛍️ ShopFlow',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                Consumer<CartService>(
                  builder: (context, cartService, child) {
                    final itemCount = cartService.itemCount;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CartPage()),
                            );
                          },
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (itemCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                itemCount > 9 ? '9+' : itemCount.toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Découvrez nos produits premium',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _filterProducts(),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un produit...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ProductService.getCategories().length,
                        itemBuilder: (context, index) {
                          final category = ProductService.getCategories()[index];
                          final isSelected = category == _selectedCategory;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected 
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                _filterProducts();
                              },
                              backgroundColor: theme.colorScheme.surface,
                              selectedColor: theme.colorScheme.primary,
                              checkmarkColor: theme.colorScheme.onPrimary,
                              side: BorderSide(
                                color: isSelected 
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _filteredProducts[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + (index * 50)),
                      curve: Curves.easeInOut,
                      child: ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  ProductDetailsPage(product: product),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                        onAddToCart: () {
                          context.read<CartService>().addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ \${product.name} ajouté au panier',
                                style: TextStyle(color: theme.colorScheme.onPrimary),
                              ),
                              backgroundColor: theme.colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: _filteredProducts.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
