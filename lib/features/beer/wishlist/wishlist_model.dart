import '../beer_model.dart';

class WishlistItem {
  final Beer beer;
  final String? addedAt;

  WishlistItem({required this.beer, this.addedAt});

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(beer: Beer.fromJson(json), addedAt: json['added_at']);
  }
}
