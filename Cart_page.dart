import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessingOrder = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (_isProcessingOrder) return;
    
    setState(() {
      _isProcessingOrder = true;
    });

    final cartService = context.read<CartService>();
    
    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Votre panier est vide'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      setState(() {
        _isProcessingOrder = false;
      });
      return;
    }

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));
    
    final orderId = await cartService.checkout();
    
    setState(() {
      _isProcessingOrder = false;
    });

    if (mounted) {
      _showOrderConfirmation(orderId);
      _tabController.animateTo(1); // Switch to orders tab
    }
  }

  void _showOrderConfirmation(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Commande confirmée !',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Numéro: \${orderId.substring(0, 8).toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continuer',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
        title: Text(
          'Mon Panier',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_cart), text: 'Panier'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Commandes'),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: theme.colorScheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCartTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildCartTab() {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final theme = Theme.of(context);
        
        if (cartService.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre panier est vide',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajoutez des produits pour commencer',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartService.items.length,
                itemBuilder: (context, index) {
                  final item = cartService.items[index];
                  return _buildCartItem(item, cartService);
                },
              ),
            ),
            _buildCheckoutSection(cartService),
          ],
        );
      },
    );
  }

  Widget _buildCartItem(CartItem item, CartService cartService) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/3/3f/Dash_the_dart_mascot.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: theme.colorScheme.surface,
                    child: Icon(
                      Icons.image_outlined,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\${item.product.price.toStringAsFixed(2)} €',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                cartService.updateQuantity(
                                  item.product,
                                  item.quantity - 1,
                                );
                              },
                              icon: Icon(
                                Icons.remove,
                                size: 18,
                                color: theme.colorScheme.onSurface,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                item.quantity.toString(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                cartService.updateQuantity(
                                  item.product,
                                  item.quantity + 1,
                                );
                              },
                              icon: Icon(
                                Icons.add,
                                size: 18,
                                color: theme.colorScheme.onSurface,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\${item.totalPrice.toStringAsFixed(2)} €',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => cartService.removeFromCart(item.product),
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(CartService cartService) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sous-total',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '\${cartService.totalAmount.toStringAsFixed(2)} €',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Livraison',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Gratuite',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '\${cartService.totalAmount.toStringAsFixed(2)} €',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessingOrder ? null : _processCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isProcessingOrder
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Passer la commande',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final theme = Theme.of(context);
        
        if (cartService.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune commande',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vos commandes apparaîtront ici',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cartService.orders.length,
          itemBuilder: (context, index) {
            final order = cartService.orders[index];
            return _buildOrderItem(order);
          },
        );
      },
    );
  }

  Widget _buildOrderItem(OrderModel order) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${order.statusIcon} Commande \${order.id.substring(0, 8).toUpperCase()}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Passée le \${order.formattedDate}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '\${order.items.length} article(s) - Total: \${order.total.toStringAsFixed(2)} €',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.netwo
