import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'beer_detail/beer_detail_view.dart';
import './wishlist/wishlist_view.dart';
import 'collection/collection_view_model.dart';
import 'collection/collection_model.dart';

class BeerView extends StatefulWidget {
  const BeerView({super.key});

  @override
  State<BeerView> createState() => _BeerViewState();
}

class _BeerViewState extends State<BeerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CollectionViewModel>().loadUserCollection();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CollectionViewModel>();
    final isLoading = vm.isLoading;
    final userBeers = vm.userCollection;

    // final sortedBeers = List<CollectionItem>.from(userBeers)
    //   ..sort((a, b) => (b.userRating ?? 0).compareTo(a.userRating ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F7),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Collection",
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeaderFilters(),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF0097A7),
              onRefresh: () =>
                  context.read<CollectionViewModel>().loadUserCollection(),
              child: _buildBody(isLoading, userBeers),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isLoading, List<CollectionItem> items) {
    if (isLoading && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0097A7)),
      );
    }

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Center(child: Text("Aucune bière dans votre collection")),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildBeerCard(context, items[index]);
      },
    );
  }

  // UI Components
  Widget _buildHeaderFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: _buildHeaderButton(
              "Tri: Note",
              const Color(0xFF0097A7),
              onTap: () {
                // TODO: Add sorting logic
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildHeaderButton(
              "Liste de souhaits",
              const Color(0xFF689F38),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const WishlistView()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String label, Color color, {VoidCallback? onTap}) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBeerCard(BuildContext context, CollectionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),

          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showOptions(context, item);
          },
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BeerDetailView(
                  beer: item.beer,
                  collectionItem: item,
                  isFromCollection: true,
                ),
              ),
            );
          },

          splashColor: const Color.fromARGB(
            255,
            142,
            142,
            142,
          ).withValues(alpha: 0.1),
          highlightColor: const Color.fromARGB(
            255,
            133,
            133,
            133,
          ).withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildBeerImage(item.beer.imageUrl),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.beer.brand,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Text(
                        item.beer.genericName ?? "Inconnu",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                _buildRatingDisplay(
                  (item.rating == null || item.rating == 0)
                      ? "--"
                      : item.rating!.toStringAsFixed(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeerImage(String? url) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
    return Container(
      color: const Color.fromARGB(255, 139, 139, 139),
      child: const Icon(Icons.sports_bar, color: Colors.amber),
    );
  }

  Widget _buildRatingDisplay(String rating) {
    return Row(
      children: [
        Text(
          rating,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star, color: Colors.amber, size: 20),
      ],
    );
  }

  void _showOptions(BuildContext context, CollectionItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    item.beer.brand,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Color.fromARGB(255, 205, 33, 21),
                  ),
                  title: const Text(
                    "Supprimer de ma collection",
                    style: TextStyle(color: Color.fromARGB(255, 203, 27, 14)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeletion(context, item);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel_outlined),
                  title: const Text("Annuler"),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletion(BuildContext context, CollectionItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer ?"),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Text(
          "Voulez-vous vraiment retirer ${item.beer.brand} de votre collection ?",
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await context.read<CollectionViewModel>().removeFromCollection(
                  item.beer.id,
                );

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Bière retirée de la collection"),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Erreur : $e"),
                    backgroundColor: const Color.fromARGB(255, 195, 16, 3),
                  ),
                );
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
