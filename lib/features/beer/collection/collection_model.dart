import '../beer_model.dart';

class CollectionItem {
  final Beer beer;
  final double? rating;
  final String? createdAt;
  final String? beerColor;
  final String? headColor;
  final String? headRetention;
  final String? clarity;
  final String? carbonation;
  final String? bitterness;
  final String? observations;

  CollectionItem({
    required this.beer,
    this.rating,
    this.createdAt,
    this.beerColor,
    this.headColor,
    this.headRetention,
    this.clarity,
    this.carbonation,
    this.bitterness,
    this.observations,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      beer: Beer.fromJson(json),
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      createdAt: json['created_date'],
      beerColor: json['beerColor'],
      headColor: json['headColor'],
      headRetention: json['headRetention'],
      clarity: json['clarity'],
      carbonation: json['carbonation'],
      bitterness: json['bitterness'],
      observations: json['observations'],
    );
  }
}
