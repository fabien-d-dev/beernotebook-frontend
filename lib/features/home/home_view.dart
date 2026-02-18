import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_view_model.dart';
import 'catalog/catalog_view.dart';
import 'article/article_view.dart';
import 'add_beer/add_beer_view.dart';
import '../auth/auth_view_model.dart';
import './add_beer/add_beer_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadArticles();
    });
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
              _buildDashboardButton(Icons.qr_code_scanner, "Scanner"),
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
                : PageView.builder(
                    itemCount: homeVM.articles.length,
                    itemBuilder: (context, index) {
                      final article = homeVM.articles[index];
                      final String? dbImage = article['image'];
                      final String displayImage =
                          (dbImage != null && dbImage.isNotEmpty)
                          ? dbImage
                          : 'https://images.unsplash.com/photo-1535958636474-b021ee887b13?q=80&w=1000&auto=format&fit=crop';

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
                          displayImage,
                        ),
                      );
                    },
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

  Widget _buildArticleSlide(String title, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
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
              const Color.fromARGB(222, 0, 0, 0).withValues(),
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
