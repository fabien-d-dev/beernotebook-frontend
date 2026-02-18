import 'package:flutter/material.dart';
import '../../beer_model.dart';
import '../../collection/collection_model.dart';

class TastingPanel extends StatefulWidget {
  final Beer beer;
  final CollectionItem? initialItem;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onClose;

  const TastingPanel({
    super.key,
    required this.beer,
    this.initialItem,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<TastingPanel> createState() => _TastingPanelState();
}

class _TastingPanelState extends State<TastingPanel> {
  double _couleur = 0;
  double _transparence = 0;
  double _amertume = 0;
  final TextEditingController _obsController = TextEditingController();
  bool _isEditing = false;

  final List<String> colors = ["Blonde", "Ambrée", "Brune", "Noire"];
  final List<String> clarities = ["Limpide", "Trouble", "Opaque"];
  final List<String> bitternessLevels = ["Faible", "Moyenne", "Forte"];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final item = widget.initialItem;

    _obsController.text = item?.observations ?? "";

    if (item != null) {
      if (item.beerColor != null) {
        int idx = colors.indexOf(item.beerColor!);
        if (idx != -1) _couleur = idx.toDouble();
      }
      if (item.clarity != null) {
        int idx = clarities.indexOf(item.clarity!);
        if (idx != -1) _transparence = idx.toDouble();
      }
      if (item.bitterness != null) {
        int idx = bitternessLevels.indexOf(item.bitterness!);
        if (idx != -1) _amertume = idx.toDouble();
      }

      _isEditing =
          (item.observations == null || item.observations!.isEmpty) &&
          item.beerColor == null;
    } else {
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 15),
          _isEditing ? _buildEditForm() : _buildReadView(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dégustation",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (!_isEditing)
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
            onPressed: () => setState(() => _isEditing = true),
          ),
      ],
    );
  }

  Widget _buildReadView() {
    final item = widget.initialItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadOnlyRow("Couleur", item?.beerColor ?? "Non renseigné"),
        _buildReadOnlyRow("Clarté", item?.clarity ?? "Non renseigné"),
        _buildReadOnlyRow("Amertume", item?.bitterness ?? "Non renseigné"),
        const Divider(),
        const Text(
          "Observations:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          (item?.observations == null || item!.observations!.isEmpty)
              ? "Aucune note particulière."
              : item.observations!,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _buildTastingSlider(
          "Couleur:",
          _couleur,
          (v) => setState(() => _couleur = v),
          colors,
        ),
        _buildTastingSlider(
          "Transparence:",
          _transparence,
          (v) => setState(() => _transparence = v),
          clarities,
        ),
        _buildTastingSlider(
          "Amertume:",
          _amertume,
          (v) => setState(() => _amertume = v),
          bitternessLevels,
        ),
        TextField(
          controller: _obsController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: "Observations",
            hintText: "Arômes, température, contexte...",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        _buildActionBtn("Sauvegarder", const Color(0xFF689F38), () {
          widget.onSave({
            'beerColor': colors[_couleur.toInt()],
            'clarity': clarities[_transparence.toInt()],
            'bitterness': bitternessLevels[_amertume.toInt()],
            'observations': _obsController.text,
          });
          setState(() => _isEditing = false);
        }),
      ],
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildTastingSlider(
    String label,
    double value,
    Function(double) onChanged,
    List<String> labels,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 0,
          max: (labels.length - 1).toDouble(),
          divisions: labels.length - 1,
          activeColor: const Color(0xFF0097A7),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map((l) => Text(l, style: const TextStyle(fontSize: 10)))
              .toList(),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildActionBtn(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
