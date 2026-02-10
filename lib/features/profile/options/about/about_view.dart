import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  Future<void> _launchDiscord() async {
    final Uri url = Uri.parse('https://discord.gg/kyyWB8hpBX');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Retour Options",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "À propos de BeerNotebook",
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 15),
            _buildParagraph(
              "L'application a été conçue autour d'une idée commune : répertorier les bières consommées tout en offrant la possibilité de les noter. Le carnet de bières, toujours à portée de main.",
            ),

            _buildSubtitle("Découvrez, Enregistrez et Partagez"),
            _buildParagraph(
              "Avec BeerNotebook, gardez une trace de toutes les bières que vous avez dégustées. Prenez des notes, ajoutez des photos et enregistrez les informations essentielles comme le nom de la bière, la brasserie, le type, le degré d'alcool et votre propre évaluation.",
            ),
            _buildParagraph(
              "Utilisez la fonction de scanner pour identifier facilement les bières par code-barres et ajoutez-les en un instant à votre collection.",
            ),

            _buildSubtitle("Publicité et Abonnement"),
            _buildParagraph(
              "À terme, notre modèle gratuit pourrait inclure des annonces publicitaires pour couvrir les coûts de location du serveur et de maintenance.",
            ),
            _buildParagraph(
              "Cependant, les abonnés Premium bénéficient d'une expérience sans publicité, d'un espace de stockage étendu et d'un accès exclusif aux fonctionnalités avancées.",
            ),

            _buildSubtitle("Une Communauté et des Suggestions d'Évolution"),
            _buildParagraph(
              "BeerNotebook est en constante évolution, et vos suggestions sont les bienvenues !",
            ),

            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 17,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: "Rejoignez notre communauté sur "),
                  TextSpan(
                    text: "Discord",
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _launchDiscord,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            _buildParagraph(
              "Vous aurez la possibilité de discuter avec d'autres amateurs de bière, de signaler des bugs et de partager vos idées pour améliorer l'application.",
            ),
            _buildParagraph(
              "Merci d'utiliser BeerNotebook et de faire partie de cette aventure ! Nous sommes impatients de vous accompagner dans chaque nouvelle dégustation.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 17,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSubtitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}
