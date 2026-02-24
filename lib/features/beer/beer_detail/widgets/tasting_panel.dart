import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  double _headColor = 0;
  double _headRetention = 0;
  double _carbonation = 0;

  final TextEditingController _obsController = TextEditingController();
  bool _isEditing = false;

  final List<String> colors = [" ", "Blonde", "Ambrée", "Brune", "Noire"];
  final List<String> clarities = [" ", "Limpide", "Trouble", "Opaque"];
  final List<String> bitternessLevels = [" ", "Faible", "Moyenne", "Forte"];
  final List<String> headColors = [" ", "Blanche", "Ivoire", "Beige", "Rousse"];
  final List<String> headRetentions = [" ", "Nulle", "Faible", "Persistante"];
  final List<String> carbonations = [" ", "Faible", "Moyenne", "Pétillante"];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final item = widget.initialItem;
    _obsController.text = item?.observations ?? "";

    if (item != null) {
      
      int getIndex(List<String> list, String? value) =>
          value != null ? list.indexOf(value) : 0;

      _couleur = getIndex(colors, item.beerColor).toDouble();
      _transparence = getIndex(clarities, item.clarity).toDouble();
      _amertume = getIndex(bitternessLevels, item.bitterness).toDouble();
      _headColor = getIndex(headColors, item.headColor).toDouble();
      _headRetention = getIndex(headRetentions, item.headRetention).toDouble();
      _carbonation = getIndex(carbonations, item.carbonation).toDouble();

      _isEditing = (item.beerColor == null && _obsController.text.isEmpty);
    } else {
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  void _handleSave() {
    String? mapVal(List<String> list, double value) =>
        value == 0 ? null : list[value.toInt()];

    widget.onSave({
      'beerColor': mapVal(colors, _couleur),
      'clarity': mapVal(clarities, _transparence),
      'bitterness': mapVal(bitternessLevels, _amertume),
      'headColor': mapVal(headColors, _headColor),
      'headRetention': mapVal(headRetentions, _headRetention),
      'carbonation': mapVal(carbonations, _carbonation),
      'observations': _obsController.text.trim(),
    });
    setState(() => _isEditing = false);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "Non datée";
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy à HH:mm').format(dateTime);
    } catch (e) {
      return "Date invalide";
    }
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
        if (item?.createdAt != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10),
            child: Text(
              "Dégustée le : ${_formatDate(item!.createdAt)}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        _buildReadOnlyRow("Robe", item?.beerColor ?? "Non renseigné"),
        _buildReadOnlyRow("Transparence", item?.clarity ?? "Non renseigné"),
        _buildReadOnlyRow(
          "Mousse (Couleur)",
          item?.headColor ?? "Non renseigné",
        ),
        _buildReadOnlyRow(
          "Mousse (Persistance)",
          item?.headRetention ?? "Non renseigné",
        ),
        _buildReadOnlyRow("Effervescence", item?.carbonation ?? "Non renseigné"),
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
          "Couleur Robe:",
          _couleur,
          (v) => setState(() => _couleur = v),
          colors,
          "Couleur",
        ),
        _buildTastingSlider(
          "Transparence:",
          _transparence,
          (v) => setState(() => _transparence = v),
          clarities,
          "Transparence",
        ),
        _buildTastingSlider(
          "Mousse (Couleur):",
          _headColor,
          (v) => setState(() => _headColor = v),
          headColors,
          "Mousse",
        ),
        _buildTastingSlider(
          "Mousse (Persistance):",
          _headRetention,
          (v) => setState(() => _headRetention = v),
          headRetentions,
          "Gris",
        ),
        _buildTastingSlider(
          "Effervescence:",
          _carbonation,
          (v) => setState(() => _carbonation = v),
          carbonations,
          "Bleu",
        ),
        _buildTastingSlider(
          "Amertume:",
          _amertume,
          (v) => setState(() => _amertume = v),
          bitternessLevels,
          "Amertume",
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _obsController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: "Observations",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        _buildActionBtn("Sauvegarder", const Color(0xFF689F38), _handleSave),
      ],
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTastingSlider(
    String label,
    double value,
    Function(double) onChanged,
    List<String> labels,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ${labels[value.toInt()]}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 5),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildSliderBackground(labels, type),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: const Color(0xFF0097A7),
                trackHeight: 10,
              ),
              child: Slider(
                value: value,
                min: 0,
                max: (labels.length - 1).toDouble(),
                divisions: labels.length - 1,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSliderBackground(List<String> labels, String type) {
    List<Color> barColors = [];
    switch (type) {
      case "Couleur":
        barColors = [
          Colors.grey.shade300,
          Colors.yellow.shade200,
          Colors.orange.shade700,
          Colors.brown.shade800,
          Colors.black,
        ];
        break;
      case "Transparence":
        barColors = [
          Colors.grey.shade300,
          const Color.fromARGB(108, 255, 153, 0).withValues(),
          const Color.fromARGB(168, 255, 153, 0).withValues(),
          Colors.orange,
        ];
        break;
      case "Mousse":
        barColors = [
          Colors.grey.shade300,
          Colors.white,
          Colors.grey.shade200,
          Colors.orange.shade100,
          Colors.brown.shade200,
        ];
        break;
      case "Bleu":
        barColors = [
          Colors.grey.shade300,
          Colors.grey.shade300,
          Colors.grey.shade300,
          Colors.grey.shade300,
        ];
        break;
      case "Amertume":
        barColors = [
          Colors.grey.shade300,
          Colors.green.shade100,
          Colors.green.shade400,
          Colors.green.shade900,
        ];
        break;
      default:
        barColors = [
          Colors.grey.shade300,
          Colors.grey.shade400,
          Colors.grey.shade600,
          Colors.grey.shade800,
        ];
    }

    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(colors: barColors),
      ),
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
