import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../beer_model.dart';
import '../collection/collection_view_model.dart';
import '../collection/collection_model.dart';
import '../wishlist/wishlist_view_model.dart';
import '../../auth/auth_view_model.dart';

import './widgets/rating_section.dart';
import './widgets/tasting_panel.dart';
import '../../../core/widgets/action_button.dart';

class BeerDetailView extends StatefulWidget {
  final Beer beer;
  final CollectionItem? collectionItem;
  final bool isFromCollection;
  final bool isFromWishlist;
  final bool isFromCatalog;

  const BeerDetailView({
    super.key,
    required this.beer,
    this.collectionItem,
    this.isFromCollection = false,
    this.isFromWishlist = false,
    this.isFromCatalog = false,
  });

  @override
  State<BeerDetailView> createState() => _BeerDetailViewState();
}

class _BeerDetailViewState extends State<BeerDetailView> {
  late double _currentRating;
  late double _originalRating;
  bool _isSavingRating = false;
  bool _isDegustationOpen = false;
  bool _isAddingToWishlist = false;
  bool _isAddingToCollection = false;
  CollectionItem? _userItem;

  @override
  void initState() {
    super.initState();

    _currentRating = widget.collectionItem?.rating ?? 0.0;
    _originalRating = _currentRating;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final collectionVM = context.read<CollectionViewModel>();

      final freshItem = collectionVM.userCollection.firstWhere(
        (it) => it.beer.id == widget.beer.id,
        orElse: () => CollectionItem(beer: widget.beer),
      );

      setState(() {
        _userItem = freshItem;
        _currentRating = freshItem.rating ?? 0.0;
        _originalRating = _currentRating;
      });
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "Récemment";
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return "Date inconnue";
    }
  }

  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: const Color.fromARGB(255, 30, 30, 30).withValues(),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: _buildBeerImage(size: 300),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeerImage({double size = 180}) {
    if (widget.beer.imageUrl != null && widget.beer.imageUrl!.isNotEmpty) {
      return Image.network(
        widget.beer.imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.sports_bar, size: size, color: const Color(0xFF0097A7)),
      );
    }
    return Icon(Icons.sports_bar, size: size, color: const Color(0xFF0097A7));
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final isPremium = authVM.isPremium;

    final collectionVM = context.watch<CollectionViewModel>();
    final bool inCollection = collectionVM.isBeerInCollection(widget.beer.id);

    final wishlistVM = context.watch<WishlistViewModel?>();
    final bool inWishlist =
        wishlistVM?.isBeerInWishlist(widget.beer.id) ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F7),
      appBar: AppBar(
        title: const Text("Retour Collection"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.beer.brand,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 3,
              width: 60,
              color: const Color(0xFF4CAF50),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.beer.genericName ?? "Inconnu",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 20),

            // MAIN BEER CARD
            _buildMainCard(context),

            const SizedBox(height: 30),

            if (widget.isFromCatalog) ...[
              // =============
              // CATALOG VIEW
              // =============
              ActionButton(
                label: inCollection
                    ? "Déjà dans ma collection"
                    : "Ajouter à ma collection",
                icon: inCollection
                    ? Icons.check_circle
                    : Icons.add_circle_outline,
                loadingLabel: "Ajout en cours...",
                color: inCollection ? Colors.grey : const Color(0xFF0097A7),
                isLoading: _isAddingToCollection,
                onPressed: inCollection ? null : _handleAddToCollection,
              ),

              const SizedBox(height: 15),

              ActionButton(
                label: inWishlist
                    ? "Dans ma wishlist"
                    : "Ajouter à ma wishlist",
                icon: inWishlist ? Icons.favorite : Icons.favorite_border,
                color: inWishlist
                    ? Colors.grey
                    : const Color.fromARGB(255, 5, 132, 83),
                isLoading: _isAddingToWishlist,
                onPressed: inWishlist ? null : _handleAddToWishlist,
              ),
            ] else if (widget.isFromCollection) ...[
              // =============
              // COLLECTION VIEW
              // =============
              RatingSection(
                rating: _currentRating,
                initialRating: _originalRating,
                isSaving: _isSavingRating,
                onRatingChanged: (val) => setState(() => _currentRating = val),
                onSave: () async {
                  setState(() => _isSavingRating = true);
                  try {
                    await collectionVM.updateTasting(
                      widget.beer.id,
                      _currentRating,
                    );

                    setState(() {
                      _originalRating = _currentRating;
                      _isSavingRating = false;
                    });

                    if (!mounted || !context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              "Note mise à jour !",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF689F38),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(20),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    setState(() => _isSavingRating = false);
                  }
                },
              ),
              ActionButton(
                label: inWishlist
                    ? "Dans ma wishlist"
                    : "Ajouter à ma wishlist",
                icon: inWishlist ? Icons.favorite : Icons.favorite_border,
                color: inWishlist
                    ? Colors.grey
                    : const Color.fromARGB(255, 5, 132, 83),
                isLoading: _isAddingToWishlist,
                onPressed: inWishlist ? null : _handleAddToWishlist,
              ),
            ] else if (widget.isFromWishlist) ...[
              // =============
              // WISHLIST VIEW
              // =============
              ActionButton(
                label: inCollection
                    ? "Déjà dans ma collection"
                    : "Ajouter à ma collection",
                icon: inCollection
                    ? Icons.check_circle
                    : Icons.add_circle_outline,
                loadingLabel: "Ajout en cours...",
                color: inCollection ? Colors.grey : const Color(0xFF0097A7),
                isLoading: _isAddingToCollection,
                onPressed: inCollection ? null : _handleAddToCollection,
              ),
            ],

            const SizedBox(height: 30),

            // WIDGET TASTING PANEL
            if (_isDegustationOpen)
              TastingPanel(
                beer: widget.beer,
                onSave: (data) async {
                  try {
                    data['rating'] = _currentRating;
                    await collectionVM.updateTasting(
                      widget.beer.id,
                      _currentRating,
                    );

                    if (!mounted || !context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Dégustation enregistrée !"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    setState(() => _isDegustationOpen = false);
                  } catch (e) {
                    debugPrint("Erreur sauvegarde : $e");
                  }
                },
                onClose: () => setState(() => _isDegustationOpen = false),
              ),

            // ACTION BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Tasting Action
                  _buildIconButton(
                    label: _isDegustationOpen ? "Fermer" : "Déguster",
                    icon: Icons.local_drink,
                    color: const Color(0xFF0097A7),
                    onTap: () => setState(
                      () => _isDegustationOpen = !_isDegustationOpen,
                    ),
                  ),

                  // Premium Action
                  _buildIconButton(
                    label: "Infos",
                    icon: Icons.edit_note,
                    color: Colors.purple,
                    isPremiumLocked: !isPremium,
                    onTap: () {
                      if (isPremium) {
                        // Logic for adding info
                      } else {
                        _showPremiumDialog(context);
                      }
                    },
                  ),

                  // Share Action
                  _buildIconButton(
                    label: "Partager",
                    icon: Icons.qr_code_scanner,
                    color: const Color(0xFF0097A7),
                    onTap: () {
                      // Share logic
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPremiumLocked = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(10, 0, 0, 0).withValues(),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 32, color: color),
              ),

              if (isPremiumLocked)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(10, 0, 0, 0).withValues(),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showFullScreenImage(context),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Center(child: _buildBeerImage()),
              ),
            ),
            const Divider(height: 1),
            _buildInfoRow(
              "Alcool:",
              widget.beer.abv != null ? "${widget.beer.abv}% Vol." : "--",
            ),
            const Divider(height: 1),

            if (widget.beer.type != null && widget.beer.type!.isNotEmpty) ...[
              _buildInfoRow("Type:", widget.beer.type!),
              const Divider(height: 1),
            ],

            if (widget.beer.manufacturingPlace != null &&
                widget.beer.manufacturingPlace!.isNotEmpty) ...[
              _buildInfoRow("Origine:", widget.beer.manufacturingPlace!),
              const Divider(height: 1),
            ],

            if (widget.beer.quantity != null &&
                widget.beer.quantity!.isNotEmpty) ...[
              _buildInfoRow("Quantité:", widget.beer.formattedQuantity),
              const Divider(height: 1),
            ],

            if (widget.beer.ingredients != null &&
                widget.beer.ingredients!.isNotEmpty) ...[
              _buildInfoRow("Ingrédients:", widget.beer.ingredients!),
              const Divider(height: 1),
            ],

            if (widget.beer.allergens != null &&
                widget.beer.allergens!.isNotEmpty) ...[
              _buildInfoRow("Allergènes:", widget.beer.allergens!),
              const Divider(height: 1),
            ],

            if (widget.beer.hops != null && widget.beer.hops!.isNotEmpty) ...[
              _buildInfoRow("Houblons:", widget.beer.hops!),
              const Divider(height: 1),
            ],

            if (_userItem?.createdAt != null)
              _buildInfoRow(
                "Date d'ajout:",
                _formatDate(_userItem!.createdAt),
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.stars, color: Colors.amber),
              SizedBox(width: 18),
              Text("Espace Premium"),
            ],
          ),
          content: const Text(
            "La modification des informations détaillées est réservée aux membres Premium. \n\nRejoignez-nous pour personnaliser votre collection !",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Plus tard",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/subscription');
              },
              child: const Text(
                "Devenir Premium",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAddToCollection() async {
    setState(() => _isAddingToCollection = true);

    try {
      await context.read<CollectionViewModel>().addToCollection(widget.beer.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bière ajoutée avec succès !"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToCollection = false);
      }
    }
  }

  Future<void> _handleAddToWishlist() async {
    setState(() => _isAddingToWishlist = true);

    try {
      await context.read<WishlistViewModel>().addToWishlist(widget.beer.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ajouté à votre liste de souhaits !"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur wishlist : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToWishlist = false);
      }
    }
  }
}
