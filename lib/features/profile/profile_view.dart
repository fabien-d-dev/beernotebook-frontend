import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_view_model.dart';
import './options/option_view.dart';
import './subscription/subscription_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F7),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Profil",
          style: TextStyle(
            fontFamily: 'Bauhaus',
            // fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Yellow Header with Counters
            Container(
              color: const Color(0xFFF6D365),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    "Collection",
                    profileVM.collectionCount.toString(),
                  ),
                  _buildStatItem(
                    "Wishlist",
                    profileVM.wishlistCount.toString(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FUTUR UPDATE
                  // --- SECTION BADGES (NEW) ---
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     _buildSectionTitle("Mes Badges"),
                  //     TextButton(
                  //       onPressed: () => debugPrint("Voir tous les badges"),
                  //       child: const Text(
                  //         "Voir tout",
                  //         style: TextStyle(color: Color(0xFF0097A7)),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // _buildBadgeRow(context, profileVM.badges),
                  _buildSectionTitle("Informations générales"),
                  _buildInfoBox([
                    _buildInfoRow("Nom d'utilisateur", profileVM.username),
                    const Divider(),
                    _buildInfoRow("E-mail", profileVM.email),
                  ]),

                  _buildSectionTitle("Abonnement"),
                  _buildInfoBox([
                    _buildInfoRow("Type", profileVM.subscriptionType),
                    const Divider(),
                    _buildInfoRow("Date de début", profileVM.startDate),
                  ]),

                  _buildSectionTitle("Renouvellement"),
                  _buildInfoBox([
                    _buildInfoRow("Date", profileVM.renewalDate),
                    const Divider(),
                    _buildInfoRow(
                      "Automatique",
                      profileVM.isAutoRenewal ? "Activé" : "Désactivé",
                    ),
                  ]),

                  const SizedBox(height: 30),

                  // Options button (Cyan)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: FilledButton(
                      onPressed: () {
                        // Navigation to the options page
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const OptionsView(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0097A7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Options",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (profileVM.isStandardAccount)
                    // Bouton S'abonner (Vert) - Apparaît si le compte est standard
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionView(),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "S'abonner",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  else
                    // Cancel button (Red) (if premium)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: FilledButton(
                        onPressed: () {
                          debugPrint("Demande d'annulation");
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD35252),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Annuler abonnement",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildBadgeRow(
  //   BuildContext context,
  //   List<Map<String, dynamic>> badges,
  // ) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 10),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: badges.take(4).map((badge) {
  //         return GestureDetector(
  //           onTap: () => _showBadgeDetail(context, badge),
  //           child: Container(
  //             width: 70,
  //             height: 70,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(15),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 5,
  //                 ),
  //               ],
  //             ),
  //             child: Icon(
  //               badge['icon'],
  //               size: 35,
  //               color: badge['progress'] == 1.0 ? Colors.amber : Colors.grey,
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  // // --- Widget : Detail du badge (Modal) ---
  // void _showBadgeDetail(BuildContext context, Map<String, dynamic> badge) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: const EdgeInsets.all(24.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(badge['icon'], size: 80, color: Colors.amber),
  //             const SizedBox(height: 16),
  //             Text(
  //               badge['name'],
  //               style: const TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               badge['description'],
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(fontSize: 16, color: Colors.grey),
  //             ),
  //             const SizedBox(height: 20),
  //             LinearProgressIndicator(
  //               value: badge['progress'],
  //               backgroundColor: Colors.grey[200],
  //               color: const Color(0xFF0097A7),
  //               minHeight: 10,
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             const SizedBox(height: 10),
  //             Text(
  //               "${(badge['progress'] * 100).toInt()}% complété",
  //               style: const TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             if (badge['date'] != null) ...[
  //               const SizedBox(height: 15),
  //               Text(
  //                 "Obtenu le : ${badge['date']}",
  //                 style: const TextStyle(fontStyle: FontStyle.italic),
  //               ),
  //             ],
  //             const SizedBox(height: 20),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoBox(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
