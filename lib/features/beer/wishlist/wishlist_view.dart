import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wishlist_view_model.dart';
import 'wishlist_model.dart';
import '../beer_detail/beer_detail_view.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WishlistViewModel>().loadWishlist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((WishlistViewModel vm) => vm.isLoading);
    final wishlistItems = context.select(
      (WishlistViewModel vm) => vm.wishlistBeers,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F7),
      appBar: AppBar(
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Liste de souhaits",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF689F38),
        onRefresh: () => context.read<WishlistViewModel>().loadWishlist(),
        child: _buildBody(isLoading, wishlistItems),
      ),
    );
  }

  Widget _buildBody(bool isLoading, List<WishlistItem> items) {
    if (isLoading && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF689F38)),
      );
    }

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Center(
            child: Text(
              "Votre liste de souhaits est vide",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildWishlistCard(context, items[index]);
      },
    );
  }

  Widget _buildWishlistCard(BuildContext context, WishlistItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BeerDetailView(beer: item.beer),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(50, 0, 0, 0).withValues(),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildBeerImage(item.beer.imageUrl),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.beer.brand,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.beer.genericName ?? "Inconnu",
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBeerImage(String? url) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
              )
            : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(Icons.sports_bar, color: Colors.amber, size: 30);
  }
}
