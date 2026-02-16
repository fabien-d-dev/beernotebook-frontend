import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/beer_data.dart';
import 'add_beer_view_model.dart';

class AddBeerView extends StatelessWidget {
  const AddBeerView({super.key});

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
                "Ajouter une bière au catalogue",
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
            const SizedBox(height: 10),
            _buildCustomButton(
              "Caméra",
              const Color(0xFF0097A7),
              Icons.camera_alt,
              () {
                // Logic for camera
              },
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
                          () async {

                            bool success = await viewModel.submitBeer();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Bière ajoutée avec succès !",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(
                                    0xFF689F38,
                                  ), 
                                  behavior: SnackBarBehavior
                                      .floating, 
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(
                                    20,
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              Navigator.pop(context);
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
