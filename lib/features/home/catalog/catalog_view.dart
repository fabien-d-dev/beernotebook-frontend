import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../beer/beer_view_model.dart';
import '../../beer/beer_model.dart';
import '../../beer/beer_detail/beer_detail_view.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({super.key});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    // Initial fetch of the catalog data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BeerViewModel>().loadCatalog(isRefresh: true);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final beerVM = context.read<BeerViewModel>();

    if (beerVM.isLoading) return;

    if (_searchQuery.isEmpty &&
        beerVM.hasMoreCatalog &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      beerVM.loadCatalog();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final beerVM = context.watch<BeerViewModel>();

    final filteredBeers = beerVM.catalogBeers.where((beer) {
      final query = _searchQuery.toLowerCase();
      final brandMatch = beer.brand.toLowerCase().contains(query);
      final nameMatch =
          beer.genericName?.toLowerCase().contains(query) ?? false;
      return brandMatch || nameMatch;
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F2F7),
        appBar: AppBar(
          title: const Text(
            "Retour Accueil",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildSearchBar(),
            ),
          ),
        ),
        body: beerVM.isLoading && beerVM.catalogBeers.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0097A7)),
              )
            : filteredBeers.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () => beerVM.loadCatalog(isRefresh: true),
                child: ListView.builder(
                  controller: _scrollController,
                  key: ValueKey(_searchQuery),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount:
                      filteredBeers.length +
                      (beerVM.hasMoreCatalog && _searchQuery.isEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < filteredBeers.length) {
                      final beer = filteredBeers[index];
                      return _buildBeerCard(
                        context,
                        beer,
                        key: ValueKey('catalog_${beer.id}'),
                      );
                    } else {
                      return beerVM.isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0097A7),
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    }
                  },
                ),
              ),
      ),
    );
  }

  // UI Components
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: "Rechercher une marque ou un style...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF0097A7)),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = "");
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "Aucune bière trouvée",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeerCard(BuildContext context, Beer beerModel, {Key? key}) {
    final isPressed = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      key: key,
      valueListenable: isPressed,
      builder: (context, pressed, child) {
        return GestureDetector(
          onTapDown: (_) => isPressed.value = true,
          onTapUp: (_) => isPressed.value = false,
          onTapCancel: () => isPressed.value = false,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BeerDetailView(beer: beerModel),
              ),
            );
          },
          child: AnimatedScale(
            scale: pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: pressed ? 0.02 : 0.05,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildBeerImage(beerModel.imageUrl),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          beerModel.brand,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          beerModel.genericName ?? "Bière artisanale",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildAbvBadge(beerModel.abv),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBeerImage(String? url) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.sports_bar, color: Color(0xFF0097A7)),
              )
            : const Icon(Icons.sports_bar, color: Color(0xFF0097A7)),
      ),
    );
  }

  Widget _buildAbvBadge(String? abv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        abv != null ? "$abv%" : "N/A",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
