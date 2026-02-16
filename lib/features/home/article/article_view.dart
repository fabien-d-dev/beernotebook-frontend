import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleView extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleView({super.key, required this.article});

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.95) {
      if (!_showScrollTopButton) setState(() => _showScrollTopButton = true);
    } else {
      if (_showScrollTopButton) setState(() => _showScrollTopButton = false);
    }
  }

  Future<void> _openSourceLink() async {
    final String? urlString = widget.article['url'];
    if (urlString != null) {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return "";
    try {
      final date = DateTime.parse(rawDate);
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.article['title'] ?? 'Sans titre';
    final String body = widget.article['body'] ?? '';
    final String? image = widget.article['image'];
    final String source = widget.article['source_title'] ?? 'Source inconnue';

    final cleanedBody = body.replaceAll('\\"', '"');
    final paragraphs = cleanedBody
        .split('\\n\\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Retour Accueil",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: image != null
                      ? Image.network(image, fit: BoxFit.cover)
                      : Image.asset(
                          'assets/images/0004.jpg',
                          fit: BoxFit.cover,
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatDate(widget.article['date']),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 15),

                      // Body paragraphs
                      ...paragraphs.map(
                        (text) => Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            text.trim(),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Source Button
                      ElevatedButton.icon(
                        onPressed: _openSourceLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0396A6),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        icon: const Icon(Icons.link, color: Colors.white),
                        label: Text(
                          "Source: $source",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Scroll Top Button
          if (_showScrollTopButton)
            Positioned(
              bottom: 90,
              right: 17,
              child: GestureDetector(
                onTap: _scrollToTop,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0396A6),
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(135, 0, 0, 0).withValues(),
                        blurRadius: 3.84,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
