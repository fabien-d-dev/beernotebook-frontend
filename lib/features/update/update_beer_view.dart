import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/add_beer/add_beer_view_model.dart';
import '../beer/collection/collection_view_model.dart';
import '../beer/wishlist/wishlist_view_model.dart';

import '../beer/beer_detail/beer_detail_view.dart';
import '../../../core/utils/beer_data.dart';

class UpdateBeerView extends StatelessWidget {
  const UpdateBeerView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddBeerViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(243, 242, 247, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Retour Accueil",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Modifier les infos de la bière",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "* Champs obligatoires",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 20),

            if (!viewModel.isBarcodePreFilled)
              _buildInputField(
                "Numéro de produit",
                "Ex: 0123456789123",
                viewModel.barcodeController,
                isRequired: true,
              ),
            _buildInputField(
              "Brasserie",
              "Ex: Mélusine",
              viewModel.breweryController,
              isRequired: true,
            ),
            _buildInputField(
              "Nom générique",
              "Ex: Mandragore",
              viewModel.nameController,
              isRequired: true,
            ),
            _buildInputField(
              "Quantité",
              "Ex: 75",
              viewModel.quantityController,
            ),
            _buildInputField(
              "Degré d'alcool",
              "Ex: 4.5",
              viewModel.abvController,
              suffix: "% Vol.",
            ),

            const Text(
              "Image",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 15),

            if (viewModel.imageFile == null &&
                viewModel.existingImageUrl == null)
              _buildCustomButton(
                "Prendre une photo",
                const Color(0xFF0097A7),
                Icons.camera_alt,
                () => viewModel.takePhoto(),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: 150,
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: viewModel.imageFile != null
                              ? Image.file(
                                  viewModel.imageFile!,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  viewModel.existingImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Photo button
                      Expanded(
                        child: _buildCustomButton(
                          "Changer",
                          const Color(0xFF0097A7),
                          Icons.camera_alt,
                          () => viewModel.takePhoto(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Clear button
                      Expanded(
                        child: _buildCustomButton(
                          "Effacer",
                          const Color.fromARGB(255, 240, 146, 53),
                          Icons.delete,
                          () {
                            viewModel.resetPhoto();
                            viewModel.clearExistingImage();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 20),

            _buildDropdownField(
              "Origine",
              "Sélectionner une origine",
              items: BeerData.addAlphabeticalSeparators(
                BeerData.beerManufacturingPlaces,
              ),
              value: viewModel.selectedOrigin,
              onChanged: (val) => viewModel.setOrigin(val),
            ),

            _buildDropdownField(
              "Type",
              "Sélectionner le type",
              items: BeerData.addAlphabeticalSeparators(BeerData.beerTypes),
              value: viewModel.selectedType,
              onChanged: (val) => viewModel.setType(val),
            ),

            // Extra fields
            if (viewModel.showExtraFields) ...[
              const SizedBox(height: 10),
              _buildInputField(
                "Houblons",
                "Ex: Cascade, Citra",
                viewModel.hopsController,
              ),
              _buildInputField(
                "Ingrédients",
                "Ex: eau, malt",
                viewModel.ingredientsController,
              ),
              _buildInputField(
                "Allergènes",
                "Ex: gluten, orge",
                viewModel.allergensController,
              ),
            ],

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildCustomButton(
                          "Valider",
                          const Color(0xFF689F38),
                          null,
                          // Update submission
                          () async {
                            final isUpdate = viewModel.existingBeerId != null;
                            bool success;

                            if (isUpdate) {
                              success = await viewModel.updateBeer();
                            } else {
                              success = await viewModel.submitBeer();
                            }

                            if (success &&
                                context.mounted &&
                                viewModel.createdBeer != null) {
                              context
                                  .read<CollectionViewModel>()
                                  .loadUserCollection();

                              final beerResult = viewModel.createdBeer!;

                              if (isUpdate) {
                                // Success dialog for update
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Text(
                                        "Bière modifiée ! 🍺",
                                        textAlign: TextAlign.center,
                                      ),
                                      content: const Text(
                                        "Les informations ont été mises à jour avec succès.",
                                        textAlign: TextAlign.center,
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: [
                                        _buildDialogButton(
                                          context,
                                          label: "Retour aux détails",
                                          color: const Color(0xFF0097A7),
                                          icon: Icons.arrow_back,
                                          onTap: () {
                                            Navigator.pop(dialogContext);

                                            Navigator.pop(
                                              context,
                                              viewModel.createdBeer,
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                // Success dialog for creation
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Text(
                                        "Bière ajoutée ! 🍻",
                                        textAlign: TextAlign.center,
                                      ),
                                      content: const Text(
                                        "Souhaitez-vous l'ajouter à vos listes ?",
                                        textAlign: TextAlign.center,
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildDialogButton(
                                              context,
                                              label: "Ajouter à ma collection",
                                              color: const Color(0xFF0097A7),
                                              icon: Icons.inventory_2,
                                              onTap: () async {
                                                try {
                                                  // API call to link the beer to the user
                                                  await context
                                                      .read<
                                                        CollectionViewModel
                                                      >()
                                                      .addToCollection(
                                                        beerResult.id,
                                                      );

                                                  if (context.mounted) {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );

                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            BeerDetailView(
                                                              beer: beerResult,
                                                              collectionItem:
                                                                  null,
                                                              isFromCollection:
                                                                  true,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Erreur : Vérifiez les champs et la connexion.",
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                  return;
                                                }
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            _buildDialogButton(
                                              context,
                                              label: "Ajouter à ma wishlist",
                                              color: const Color.fromARGB(
                                                255,
                                                5,
                                                132,
                                                83,
                                              ),
                                              icon: Icons.favorite,
                                              onTap: () async {
                                                try {
                                                  await context
                                                      .read<WishlistViewModel>()
                                                      .addToWishlist(
                                                        beerResult.id,
                                                      );

                                                  if (context.mounted) {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );

                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            BeerDetailView(
                                                              beer: beerResult,
                                                              isFromWishlist:
                                                                  true,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  debugPrint(
                                                    "❌ Erreur wishlist: $e",
                                                  );
                                                }
                                              },
                                            ),
                                            const SizedBox(height: 5),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(dialogContext);
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "Plus tard (Retour Accueil)",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } else if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Erreur : Vérifiez les champs et la connexion.",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildCustomButton(
                    viewModel.showExtraFields ? "Moins" : "Plus",
                    viewModel.showExtraFields
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF0097A7),
                    null,
                    () => viewModel.toggleExtraFields(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPERS
  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isRequired = false,
    String? suffix,
  }) {
    TextInputType selectedKeyboard;
    if (label == "Numéro de produit" || label == "Quantité") {
      selectedKeyboard = TextInputType.number;
    } else if (label == "Degré d'alcool") {
      selectedKeyboard = const TextInputType.numberWithOptions(decimal: true);
    } else {
      selectedKeyboard = TextInputType.text;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (isRequired)
                const Text(" *", style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: selectedKeyboard,
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.white,
              filled: true,
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String hint, {
    required List<Map<String, String>> items,
    String? value,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value == '' ? null : value,
                hint: Text(hint),
                items: items.map((item) {
                  bool isSeparator =
                      item['value']?.startsWith('SEPARATOR_') ?? false;
                  return DropdownMenuItem<String>(
                    value: item['value'],
                    enabled: !isSeparator,
                    child: Text(
                      item['label'] ?? '',
                      style: TextStyle(
                        fontWeight: isSeparator
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSeparator ? Colors.grey : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton(
    String label,
    Color color,
    IconData? icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
