import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_view_model.dart';
import 'home_view_model.dart';
import 'catalog/catalog_view.dart';
import 'article/article_view.dart';
import 'add_beer/add_beer_view.dart';
import 'add_beer/add_beer_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadArticles().then((_) {
        _startAutoPlay();
      });
    });
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      final homeVM = context.read<HomeViewModel>();
      if (homeVM.articles.isNotEmpty) {
        if (_currentPage < homeVM.articles.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _resetTimer() {
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 242, 247, 1),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          homeVM.title,
          style: const TextStyle(fontFamily: 'Bauhaus', fontSize: 28),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDashboardButton(
                Icons.qr_code_scanner,
                "Scanner",
                onTap: () => Navigator.pushNamed(context, '/scan'),
              ),
              _buildDashboardButton(
                Icons.menu_book_outlined,
                "Catalogue",
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CatalogView()),
                ),
              ),
              _buildDashboardButton(
                Icons.edit_note,
                "Ajouter",
                onTap: () {
                  final authVM = Provider.of<AuthViewModel>(
                    context,
                    listen: false,
                  );

                  if (authVM.userId != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) =>
                              AddBeerViewModel(userId: authVM.userId!),
                          child: const AddBeerView(),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Erreur: Utilisateur non identifié"),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Article Title
          _buildNewsTitle(homeVM.newsTitle),
          // Article Slider
          Expanded(
            child: homeVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Listener(
                    onPointerDown: (_) => _resetTimer(),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: homeVM.articles.length,
                      onPageChanged: (index) {
                        _currentPage = index;
                      },
                      itemBuilder: (context, index) {
                        final article = homeVM.articles[index];
                        final String? dbImage = article['image'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ArticleView(article: article),
                              ),
                            );
                          },
                          child: _buildArticleSlide(
                            article['title'] ?? 'Sans titre',
                            dbImage,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(31, 0, 0, 0).withValues(),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          fontFamily: 'Quicksand',
        ),
      ),
    );
  }

  Widget _buildArticleSlide(String title, String? imageUrl) {
    final ImageProvider imageProvider =
        (imageUrl != null && imageUrl.isNotEmpty)
        ? NetworkImage(imageUrl)
        : const AssetImage('assets/images/placeholder.jpg');

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      ),
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              const Color.fromARGB(247, 0, 0, 0).withValues(),
            ],
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 100,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(20, 0, 0, 0).withValues(),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF0097A7)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
